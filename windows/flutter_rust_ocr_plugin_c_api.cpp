#include "include/flutter_rust_ocr/flutter_rust_ocr_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_rust_ocr_plugin.h"

void FlutterRustOcrPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_rust_ocr::FlutterRustOcrPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
