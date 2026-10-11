import 'package:flutter_test/flutter_test.dart';
import 'package:daisy_ui/daisy_ui.dart';
import 'package:daisy_ui/daisy_ui_platform_interface.dart';
import 'package:daisy_ui/daisy_ui_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDaisyUiPlatform
    with MockPlatformInterfaceMixin
    implements DaisyUiPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final DaisyUiPlatform initialPlatform = DaisyUiPlatform.instance;

  test('$MethodChannelDaisyUi is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDaisyUi>());
  });

  test('getPlatformVersion', () async {
    DaisyUi daisyUiPlugin = DaisyUi();
    MockDaisyUiPlatform fakePlatform = MockDaisyUiPlatform();
    DaisyUiPlatform.instance = fakePlatform;

    expect(await daisyUiPlugin.getPlatformVersion(), '42');
  });
}
