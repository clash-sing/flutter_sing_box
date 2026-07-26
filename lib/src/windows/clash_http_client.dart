import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box/src/data/models/clash/clash_api_proxy.dart';
import 'package:flutter_sing_box/src/data/models/clash/clash_configs.dart';
import 'package:flutter_sing_box/src/data/models/client/client_clash_mode.dart';

/// ws://127.0.0.1:9090/connections?token=
/// ws://127.0.0.1:9090/memory?token=
/// ws://127.0.0.1:9090/traffic?token=

class ClashHttpClient {
  ClashHttpClient._();
  static final ClashHttpClient _instance = ClashHttpClient._();
  factory ClashHttpClient() => _instance;
  // ignore: unused_field
  static const String _wsBaseUrl = 'ws://127.0.0.1:9090';

  Dio? _dio;
  int? _dioPort;

  Dio get dio {
    final port = CsSettingsStorage().getClashApiPort();
    if (_dio == null || _dioPort != port) {
      _dio = _buildDio(port); //     端口变了 → 整个 dio 重建,新 baseUrl 含新端口
      _dioPort = port;
    }
    return _dio!;
  }

  Dio _buildDio(int port) {
    final options = BaseOptions(
      baseUrl: 'http://127.0.0.1:$port',
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 5),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    );
    final Dio dio = Dio(options);
    dio.interceptors.add(LogInterceptor());
    return dio;
  }

  Future<void> setClashMode(String mode) async {
    final response = await dio.patch('/configs', data: {'mode': mode});
    debugPrint('Set clash mode response date: ${response.data}');
  }

  /// 拉取 /configs 并映射为代理模式,供连接成功后刷新 clashModeStream。
  /// 将 [ClashConfigs] 映射为 UI 层使用的 [ClientClashMode]。
  Future<ClientClashMode> getClashMode() async {
    final response = await dio.get('/configs');
    final Map<String, dynamic> map = response.data is Map
        ? response.data
        : jsonDecode(response.data);
    final configs = ClashConfigs.fromJson(map);
    return ClientClashMode(modes: configs.modeList, currentMode: configs.mode);
  }

  Future<void> setOutbound({required String groupTag, required String outboundTag}) async {
    final response = await dio.put('/proxies/$groupTag', data: {'name': outboundTag});
    debugPrint('setOutbound response date: ${response.data}');
  }

  Future<List<ClientGroup>> getGroups() async {
    final response = await dio.get('/proxies');
    final Map<String, dynamic> map = response.data is Map
        ? response.data
        : jsonDecode(response.data);

    final Map<String, dynamic> proxiesMap = map['proxies'];
    final List<ClashApiProxy> proxies = proxiesMap.entries.map((entry) {
      return ClashApiProxy.fromJson(entry.value as Map<String, dynamic>);
    }).toList();
    final groupProxies = proxies
        .where((proxy) => proxy.type == _ProxyType.urlTest || proxy.type == _ProxyType.selector)
        .toList();
    final List<ClientGroup> groups = groupProxies.map((proxy) {
      return ClientGroup(
        tag: proxy.name,
        type: _convert2OutboundType(proxy.type),
        selectable: proxy.type != _ProxyType.urlTest,
        selected: proxy.now ?? '',
        isExpand: false,
        items: proxy.all?.map((item) {
          ClashApiProxy proxyItem = proxies.firstWhere((p) => p.name == item);
          return ClientGroupItem(
            tag: proxyItem.name,
            type: _convert2OutboundType(proxyItem.type),
            urlTestTime: proxyItem.histories.isNotEmpty
                ? proxyItem.histories.first.localTime.millisecondsSinceEpoch
                : 0,
            urlTestDelay: proxyItem.histories.isNotEmpty ? proxyItem.histories.first.delay : 0,
          );
        }).toList(),
      );
    }).toList();
    return groups;
  }

  Future<void> testGroup(String groupTag) async {
    final params = 'timeout=5000&url=${Uri.encodeQueryComponent(CsSettingsStorage().getTestUrl())}';
    final response = await dio.get('/group/${Uri.encodeQueryComponent(groupTag)}/delay?$params');
    debugPrint('testGroup response date: ${response.data}');
  }

  static String _convert2OutboundType(String type) {
    switch (type) {
      case _ProxyType.selector:
        return OutboundType.selector;
      case _ProxyType.urlTest:
        return OutboundType.urltest;
      case _ProxyType.direct:
        return OutboundType.direct;
      default:
        return type.toLowerCase();
    }
  }
}

abstract class _ProxyType {
  // ignore: unused_field
  static const String fallback = 'Fallback';
  static const String selector = 'Selector';
  static const String direct = 'Direct';
  static const String urlTest = 'URLTest';
}
