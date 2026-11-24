#ifndef FLUTTER_PLUGIN_FLUTTER_RUST_OCR_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_RUST_OCR_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>

namespace flutter_rust_ocr {

class FlutterRustOcrPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterRustOcrPlugin();

  virtual ~FlutterRustOcrPlugin();

  FlutterRustOcrPlugin(const FlutterRustOcrPlugin&) = delete;
  FlutterRustOcrPlugin& operator=(const FlutterRustOcrPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_rust_ocr

#endif  // FLUTTER_PLUGIN_FLUTTER_RUST_OCR_PLUGIN_H_
