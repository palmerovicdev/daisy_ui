#include "include/daisy_ui/daisy_ui_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "daisy_ui_plugin.h"

void DaisyUiPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  daisy_ui::DaisyUiPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
