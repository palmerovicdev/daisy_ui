//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <daisy_ui/daisy_ui_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) daisy_ui_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "DaisyUiPlugin");
  daisy_ui_plugin_register_with_registrar(daisy_ui_registrar);
}
