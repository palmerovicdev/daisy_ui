
import 'daisy_ui_platform_interface.dart';

class DaisyUi {
  Future<String?> getPlatformVersion() {
    return DaisyUiPlatform.instance.getPlatformVersion();
  }
}
