import 'dart:convert';
import 'dart:ffi';

import 'package:flutter_sing_box/src/profile/profile.dart';

import '../../flutter_sing_box.dart';

/// Example:
///   content-disposition: attachment;filename*=UTF-8''%E7%8B%97%E7%8B%97%E5%8A%A0%E9%80%9F.com
///   profile-title: base64:5LiJ5q+b5py65Zy6
///   profile-update-interval: 24
///   profile-web-page-url: https://panel.dg5.biz
///   subscription-userinfo: upload=8761515695; download=60139076905; total=214748364800; expire=1777514961
///   content-type: text/html; charset=UTF-8
class RemoteProfileService {
  Future<Profile> importProfile(Uri link, {String? name, required bool autoUpdate, int? autoUpdateInterval}) async {
    final apiResult = await networkService.fetchSubscription(link);
    final userInfo = _getUserInfo(apiResult.headers);
    final typedProfile = _getTypedProfile(link, apiResult.headers, autoUpdate, autoUpdateInterval);
    final profileName = _getProfileName(link, name, apiResult.headers);

    final profile = profileManager.addProfile( Profile(
      name: profileName,
      typed: typedProfile,
      userInfo: userInfo,
    ));

    return profile;
  }

  String _getProfileName(Uri link, String? name, Map<String, dynamic> headers) {
    if (name != null && name.trim().isNotEmpty) {
      return name;
    }
    String? profileName;
    if (headers.containsKey('content-disposition')) {
      final contentDisposition = headers['content-disposition'][0];
      const splitTag = '\'\'';
      int tagIndex = contentDisposition?.lastIndexOf(splitTag) ?? -1;
      if (tagIndex != -1) {
        String encodeString = contentDisposition.substring(tagIndex + splitTag.length);
        profileName = Uri.decodeFull(encodeString);
      }
    } else if (headers.containsKey('profile-title')) {
      final String profileTitle = headers['profile-title'][0];
      const base64Prefix = 'base64:';
      int tagIndex = profileTitle.indexOf(base64Prefix);
      if (tagIndex != -1) {
        List<int> bytes = base64Decode(profileTitle.substring(tagIndex + base64Prefix.length));
        profileName = utf8.decode(bytes);
      }
    }
    if (profileName == null || profileName.trim().isEmpty) {
      return link.host;
    } else {
      return profileName;
    }
  }

  TypedProfile _getTypedProfile(Uri link, Map<String, dynamic> headers, bool autoUpdate, int? autoUpdateInterval) {
    int? updateIntervalMins;
    if (autoUpdate) {
      if (autoUpdateInterval != null && autoUpdateInterval >= 60) {
        updateIntervalMins = autoUpdateInterval;
      } else {
        final defaultUpdateIntervalHours = int.tryParse(headers['profile-update-interval']?[0]);
        updateIntervalMins = (defaultUpdateIntervalHours ?? 24) * 60;
      }
    }

    final typedProfile = TypedProfile(
      type: ProfileType.remote,
      path: '',
      lastUpdated: DateTime.now().millisecondsSinceEpoch,
      autoUpdate: autoUpdate,
      autoUpdateInterval: updateIntervalMins,
      remoteUrl: link.toString(),
      webPageUrl: headers['profile-web-page-url']?[0] ?? link.host,
    );
    return typedProfile;
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
      return UserInfo(
        upload: upload,
        download: download,
        total: total,
        expire: expire,
      );
    } else {
      return null;
    }
  }
}