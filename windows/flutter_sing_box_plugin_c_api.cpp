#include "include/flutter_sing_box/flutter_sing_box_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_sing_box_plugin.h"

void FlutterSingBoxPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_sing_box::FlutterSingBoxPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
