import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'daisy_ui_method_channel.dart';

abstract class DaisyUiPlatform extends PlatformInterface {
  /// Constructs a DaisyUiPlatform.
  DaisyUiPlatform() : super(token: _token);

  static final Object _token = Object();

  static DaisyUiPlatform _instance = MethodChannelDaisyUi();

  /// The default instance of [DaisyUiPlatform] to use.
  ///
  /// Defaults to [MethodChannelDaisyUi].
  static DaisyUiPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DaisyUiPlatform] when
  /// they register themselves.
  static set instance(DaisyUiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
