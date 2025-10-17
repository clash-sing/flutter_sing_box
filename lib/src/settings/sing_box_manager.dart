import 'package:mmkv/mmkv.dart';

class SingBoxManager {
  static final SingBoxManager _instance = SingBoxManager._internal();
  factory SingBoxManager() => _instance;

  late MMKV _mmkv;
  SingBoxManager._internal() {
    _mmkv = MMKV("cs-sing-box", mode: MMKVMode.MULTI_PROCESS_MODE);
  }

  String? get profile {
    return _mmkv.decodeString("profile");
  }

  set profile(String profile) {
    _mmkv.encodeString("profile", profile);
  }

}
final singBoxManager = SingBoxManager();