import 'package:mmkv/mmkv.dart';

class CustomManager {
  CustomManager._internal();
  static final CustomManager _instance = CustomManager._internal();
  factory CustomManager() => _instance;

  MMKV? _mmkv;

  MMKV get mmkv {
    return _mmkv ??= MMKV("cs_custom", mode: MMKVMode.MULTI_PROCESS_MODE);
  }

  void clearAll() {
    mmkv.clearAll();
  }
}