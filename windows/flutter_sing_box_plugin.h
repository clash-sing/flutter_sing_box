#ifndef FLUTTER_PLUGIN_FLUTTER_SING_BOX_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_SING_BOX_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_sing_box {

class FlutterSingBoxPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterSingBoxPlugin();

  virtual ~FlutterSingBoxPlugin();

  // Disallow copy and assign.
  FlutterSingBoxPlugin(const FlutterSingBoxPlugin&) = delete;
  FlutterSingBoxPlugin& operator=(const FlutterSingBoxPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_sing_box

#endif  // FLUTTER_PLUGIN_FLUTTER_SING_BOX_PLUGIN_H_
