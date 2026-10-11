import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'daisy_ui_platform_interface.dart';

/// An implementation of [DaisyUiPlatform] that uses method channels.
class MethodChannelDaisyUi extends DaisyUiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('daisy_ui');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
