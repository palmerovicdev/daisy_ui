#ifndef FLUTTER_PLUGIN_DAISY_UI_PLUGIN_H_
#define FLUTTER_PLUGIN_DAISY_UI_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace daisy_ui {

class DaisyUiPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  DaisyUiPlugin();

  virtual ~DaisyUiPlugin();

  // Disallow copy and assign.
  DaisyUiPlugin(const DaisyUiPlugin&) = delete;
  DaisyUiPlugin& operator=(const DaisyUiPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace daisy_ui

#endif  // FLUTTER_PLUGIN_DAISY_UI_PLUGIN_H_
