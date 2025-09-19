
import 'flutter_sing_box_platform_interface.dart';

class FlutterSingBox {
  Future<String?> getPlatformVersion() {
    return FlutterSingBoxPlatform.instance.getPlatformVersion();
  }
}
