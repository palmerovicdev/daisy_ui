import 'package:daisy_ui/daisy_ui.dart';
import 'package:daisy_ui/themes/presentation/action/button.dart';
import 'package:daisy_ui_example/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(DaisyThemeService.initialize);
  setUp(() => DaisyThemeService.setTheme(DaisyThemes.light));

  testWidgets('The preview follows the active theme', (tester) async {
    await tester.pumpWidget(const MyApp());

    Future<void> expectTheme(DaisyThemeModel theme) async {
      DaisyThemeService.setTheme(theme);
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, theme.colors.base.base);
      final ink = tester.widget<Ink>(
        find.descendant(
          of: find.byType(DaisyButton),
          matching: find.byType(Ink),
        ),
      );
      final decoration = ink.decoration! as BoxDecoration;
      expect(
        decoration.color,
        theme.colors.base.base200 ?? theme.colors.base.base,
      );
      expect(
        decoration.border!.top.color,
        theme.colors.base.base300 ?? theme.colors.base.base,
      );
      expect(decoration.border!.top.width, theme.border);
      expect(
        decoration.borderRadius,
        BorderRadius.circular(theme.radius.fields.toDouble()),
      );
      final buttonText = tester.widget<Text>(
        find.descendant(
          of: find.byType(DaisyButton),
          matching: find.text('Button'),
        ),
      );
      expect(buttonText.style!.color, theme.colors.base.content);
    }

    await expectTheme(DaisyThemes.light);
    await expectTheme(DaisyThemes.dark);
  });

  testWidgets('The preview animates the Daisy button elevation', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final button = find.byType(DaisyButton);
    expect(button, findsOneWidget);
    expect(find.text('Elevación'), findsOneWidget);

    Material buttonMaterial() => tester.widget<Material>(
      find.descendant(of: button, matching: find.byType(Material)).first,
    );

    expect(buttonMaterial().elevation, 0);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(button));
    await tester.pumpAndSettle();
    expect(buttonMaterial().elevation, 1);

    await mouse.down(tester.getCenter(button));
    await tester.pumpAndSettle();
    expect(buttonMaterial().elevation, 0);

    await mouse.up();
    await tester.pumpAndSettle();
    expect(buttonMaterial().elevation, 1);
    await mouse.removePointer();
  });

  testWidgets('The preview fits a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());

    expect(find.byType(DaisyButton), findsOneWidget);
  });
}
