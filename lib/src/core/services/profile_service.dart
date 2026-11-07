import 'dart:convert';
import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

// 旧拍平模型已删除，gen 生成模型经包级 barrel 导出，直接引入即可
import 'package:flutter_sing_box/flutter_sing_box.dart';

/// `fetchAndParse` 的结果：一次订阅「下载 + 解析」的全部产出。
///
/// 纯数据快照，不落盘不落库——配置文件写入与订阅元数据持久化均由
/// 调用方（app 侧）决定。
class SubscriptionFetchResult {
  /// 解析后的 sing-box 配置模型。
  final SingBox singBox;

  /// 订阅显示名（优先级：入参名 > 响应头推断 > 文件名 / 主机名）。
  final String name;

  /// 出站节点数（direct 与带成员的组出站不计入）。
  final int outboundsCount;

  /// 本次抓取完成时间（epoch 毫秒）。
  final int lastUpdated;

  /// 规范化后的订阅地址（`link.toString()`）。
  final String subscribeUrl;

  /// 订阅主页（响应头 `profile-web-page-url`，缺省回退链接 host）。
  final String webPageUrl;

  /// 是否本地文件订阅。
  final bool isLocalFile;

  /// 订阅用量信息（响应头 `subscription-userinfo` 解析所得，可空）。
  final UserInfo? userInfo;

  /// 构造抓取结果快照。
  const SubscriptionFetchResult({
    required this.singBox,
    required this.name,
    required this.outboundsCount,
    required this.lastUpdated,
    required this.subscribeUrl,
    required this.webPageUrl,
    required this.isLocalFile,
    this.userInfo,
  });
}

/// Example:
///   content-disposition: attachment;filename*=UTF-8''%E7%8B%97%E7%8B%97%E5%8A%A0%E9%80%9F.com
///   profile-title: base64:5LiJ5q+b5py65Zy6
///   profile-update-interval: 24
///   profile-web-page-url: https://panel.dg5.biz
///   subscription-userinfo: upload=8761515695; download=60139076905; total=214748364800; expire=1777514961
///   content-type: text/html; charset=UTF-8
class ProfileService {
  /// 下载并解析一份订阅，返回 [SubscriptionFetchResult]。
  ///
  /// 本地文件订阅（file URI）直接读文件；远程订阅经 [NetworkService]
  /// 下载。只负责「取内容 + 解析」，不做任何持久化。
  Future<SubscriptionFetchResult> fetchAndParse({
    required Uri link,
    String? name,
    String? userAgent,
  }) async {
    late final ApiResult apiResult;
    if (isLocalFile(link)) {
      File file = File(link.toFilePath());
      if (await file.exists()) {
        final String content = await file.readAsString();
        apiResult = ApiResult<String>(content, {});
      } else {
        throw Exception('File not exists');
      }
    } else {
      apiResult = await NetworkService().fetchSubscription(link, userAgent: userAgent);
    }

    final userInfo = _getUserInfo(apiResult.headers);
    final profileName = _getProfileName(link, name, apiResult.headers);

    final singBox = await SingBoxConfigProvider.provide(apiResult.data);
    return SubscriptionFetchResult(
      singBox: singBox,
      name: profileName,
      // 组出站（selector/urltest）的 outbounds 字段未收敛到判别基类，经 switch 收窄；
      // 非组出站按原语义（outbounds 为空/缺省）计入节点数
      outboundsCount: singBox.outbounds
          .where(
            (e) =>
                e.type != OutboundType.direct &&
                switch (e) {
                  SelectorOutbound(:final outbounds) => outbounds?.isNotEmpty != true,
                  UrltestOutbound(:final outbounds) => outbounds?.isNotEmpty != true,
                  _ => true,
                },
          )
          .length,
      lastUpdated: DateTime.now().millisecondsSinceEpoch,
      subscribeUrl: link.toString(),
      webPageUrl: apiResult.headers['profile-web-page-url']?[0] ?? link.host,
      isLocalFile: isLocalFile(link),
      userInfo: userInfo,
    );
  }

  /// 将原始订阅输入解析为 [Uri]。
  ///
  /// Windows 盘符路径（如 C:\... 或 C:/...）与 UNC 路径（\\server\share\...）
  /// 归一化为规范 file URI——# / 空格 / 中文等特殊字符会被正确编码，
  /// 避免被当作 fragment 分隔符截断；其余输入（file://、http(s):// 等）
  /// 按普通 URI 解析。
  static Uri parseSubscribeLink(String raw) {
    final isWindowsPath = RegExp(r'^[A-Za-z]:[\\/]').hasMatch(raw) || raw.startsWith(r'\\');
    return isWindowsPath ? Uri.file(raw, windows: true) : Uri.parse(raw);
  }

  String _getProfileName(Uri link, String? name, Map<String, dynamic> headers) {
    const contentDispositionKey = 'content-disposition';
    const profileTitleKey = 'profile-title';

    if (name?.trim().isNotEmpty == true) {
      return name!.trim();
    } else if (isLocalFile(link)) {
      return link.toFilePath().split(p.separator).last;
    }

    String? profileName;
    try {
      if (headers.containsKey(contentDispositionKey)) {
        final contentDisposition = headers[contentDispositionKey][0];
        const splitTag = '\'\'';
        int tagIndex = contentDisposition?.lastIndexOf(splitTag) ?? -1;
        if (tagIndex != -1) {
          String encodeString = contentDisposition.substring(tagIndex + splitTag.length);
          profileName = Uri.decodeFull(encodeString);
        }
      } else if (headers.containsKey(profileTitleKey)) {
        final String profileTitle = headers[profileTitleKey][0];
        const base64Prefix = 'base64:';
        int tagIndex = profileTitle.indexOf(base64Prefix);
        if (tagIndex != -1) {
          List<int> bytes = base64Decode(profileTitle.substring(tagIndex + base64Prefix.length));
          profileName = utf8.decode(bytes);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    if (profileName == null || profileName.trim().isEmpty) {
      return link.host;
    } else {
      return profileName;
    }
  }

  /// Example:
  ///   subscription-userinfo: upload=7965922; download=44478393; total=1288490188800; expire=1978600781
  UserInfo? _getUserInfo(Map<String, dynamic> headers) {
    const String userinfoKey = 'subscription-userinfo';
    if (!headers.containsKey(userinfoKey)) return null;
    List<String> pairs = headers[userinfoKey][0].toString().split(';');
    int? upload;
    int? download;
    int? total;
    int? expire;
    for (var pair in pairs) {
      List<String> keyValue = pair.trim().split('=');
      if (keyValue.length != 2) continue;
      switch (keyValue[0].toLowerCase()) {
        case 'upload':
          upload = int.tryParse(keyValue[1]);
          break;
        case 'download':
          download = int.tryParse(keyValue[1]);
          break;
        case 'total':
          total = int.tryParse(keyValue[1]);
          break;
        case 'expire':
          expire = int.tryParse(keyValue[1]);
          break;
      }
    }
    if (upload != null || download != null || total != null || expire != null) {
      return UserInfo(upload: upload, download: download, total: total, expire: expire);
    } else {
      return null;
    }
  }

  /// 判断 [link] 是否指向本地文件订阅。
  ///
  /// 仅识别规范 file URI（file:///...）；Windows 盘符 / UNC 路径
  /// 需先经 [parseSubscribeLink] 归一化。
  bool isLocalFile(Uri link) => link.isScheme('file');
}
