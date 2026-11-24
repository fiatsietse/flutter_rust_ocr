#include "flutter_rust_ocr_plugin.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>

namespace flutter_rust_ocr {

// static
void FlutterRustOcrPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "flutter_rust_ocr",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<FlutterRustOcrPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

FlutterRustOcrPlugin::FlutterRustOcrPlugin() {}

FlutterRustOcrPlugin::~FlutterRustOcrPlugin() {}

void FlutterRustOcrPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getPlatformVersion") == 0) {
    result->Success(flutter::EncodableValue("Windows"));
  } else {
    result->NotImplemented();
  }
}

}  // namespace flutter_rust_ocr
