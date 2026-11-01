import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => DaisyThemeService.setTheme(DaisyThemes.light));
  tearDown(() => DaisyThemeService.setTheme(DaisyThemes.light));

  test('Public theme views hide the mutable source behind an adapter', () {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);

    for (final theme in [DaisyThemeService.theme, controller.theme]) {
      expect(theme, isNot(isA<ValueNotifier<DaisyThemeModel>>()));
      expect(
        () => theme as ValueNotifier<DaisyThemeModel>,
        throwsA(isA<TypeError>()),
      );
      expect(theme.value, DaisyThemes.light);
    }

    expect(identical(controller.theme, controller.theme), isTrue);
    expect(identical(DaisyThemeService.theme, DaisyThemeService.theme), isTrue);
    DaisyThemeService.setTheme(DaisyThemes.dark);
    expect(DaisyThemeService.theme.value, DaisyThemes.dark);
    expect(controller.theme.value, DaisyThemes.light);
  });

  test('Controllers retain their own initial theme and updates', () {
    final first = DaisyThemeController(initialTheme: DaisyThemes.dark);
    final second = DaisyThemeController(initialTheme: DaisyThemes.cupcake);
    addTearDown(first.dispose);
    addTearDown(second.dispose);

    first.setTheme(DaisyThemes.light);
    DaisyThemeService.setTheme(DaisyThemes.dark);

    expect(first.theme.value, DaisyThemes.light);
    expect(second.theme.value, DaisyThemes.cupcake);
    expect(DaisyThemeService.theme.value, DaisyThemes.dark);
  });

  test('Theme views notify on changes and support listener removal', () {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);

    for (final (theme, setTheme)
        in <(ValueListenable<DaisyThemeModel>, void Function(DaisyThemeModel))>[
          (DaisyThemeService.theme, DaisyThemeService.setTheme),
          (controller.theme, controller.setTheme),
        ]) {
      var notifications = 0;
      void listener() => notifications++;

      theme.addListener(listener);
      expect(notifications, 0);
      setTheme(DaisyThemes.light.copyWith());
      expect(notifications, 0);
      setTheme(DaisyThemes.dark);
      expect(notifications, 1);
      expect(theme.value, DaisyThemes.dark);
      theme.removeListener(listener);
      setTheme(DaisyThemes.cupcake);
      expect(notifications, 1);
    }
  });
}
