import 'package:daisy_ui/daisy_ui.dart';
import 'package:daisy_ui_example/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(DaisyThemeService.initialize);
  setUp(() => DaisyThemeService.setTheme(DaisyThemes.light));

  Finder sizedButton(DaisyButtonSize size, DaisyButtonModifier modifier) =>
      find.descendant(
        of: find.byKey(ValueKey('sizes-${modifier.name}-${size.name}')),
        matching: find.byType(DaisyButton),
      );

  testWidgets('The gallery presents the button variants', (tester) async {
    await tester.pumpWidget(const MyApp());
    for (final title in [
      'Button sizes',
      'Responsive button',
      'Button colors',
      'Soft buttons',
      'Outline buttons',
      'Dash buttons',
      'Active buttons',
      'Ghost and link buttons',
      'Disabled buttons',
      'Square and circle buttons',
      'Button with icon',
      'Block button',
      'Button with loading spinner',
      'Login buttons (unbranded examples)',
    ]) {
      expect(find.text(title), findsOneWidget, reason: title);
    }
  });

  testWidgets('Color sections use real button types and active state', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    for (final entry in {
      'Button colors': DaisyButtonType.filled,
      'Soft buttons': DaisyButtonType.soft,
      'Outline buttons': DaisyButtonType.outlined,
      'Dash buttons': DaisyButtonType.dashed,
      'Active buttons': DaisyButtonType.filled,
    }.entries) {
      final section = find.byKey(ValueKey('section-${entry.key}'));
      final buttons = tester
          .widgetList<DaisyButton>(
            find.descendant(of: section, matching: find.byType(DaisyButton)),
          )
          .toList();
      expect(buttons.length, DaisyButtonStyle.values.length);
      expect(
        buttons.map((button) => button.theme.style).toSet(),
        DaisyButtonStyle.values.toSet(),
      );
      expect(
        buttons.every((button) => button.theme.type == entry.value),
        isTrue,
      );
      expect(
        buttons.every(
          (button) => button.active == (entry.key == 'Active buttons'),
        ),
        isTrue,
      );
    }
  });

  testWidgets('Tapping an example changes the theme', (tester) async {
    await tester.pumpWidget(const MyApp());
    final button = sizedButton(DaisyButtonSize.md, DaisyButtonModifier.wide);
    await tester.ensureVisible(button);
    await tester.pump();
    await tester.tap(button);
    await tester.pump();
    expect(DaisyThemeService.theme.value, DaisyThemes.values[1]);
  });

  testWidgets('The preview follows the active theme', (tester) async {
    await tester.pumpWidget(const MyApp());
    final button = sizedButton(DaisyButtonSize.md, DaisyButtonModifier.square);
    for (final theme in [DaisyThemes.light, DaisyThemes.dark]) {
      DaisyThemeService.setTheme(theme);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        theme.colors.base.base,
      );
      final material = tester.widget<Material>(
        find.descendant(of: button, matching: find.byType(Material)).first,
      );
      expect(material.color, theme.colors.neutral.base);
      final text = find.descendant(of: button, matching: find.text('md'));
      expect(
        DefaultTextStyle.of(tester.element(text)).style.color,
        theme.colors.neutral.content,
      );
    }
  });

  testWidgets('The preview shows each size in both rows', (tester) async {
    await tester.pumpWidget(const MyApp());
    for (final size in DaisyButtonSize.values) {
      expect(sizedButton(size, DaisyButtonModifier.square), findsOneWidget);
      expect(sizedButton(size, DaisyButtonModifier.wide), findsOneWidget);
    }
  });

  testWidgets('The preview animates the Daisy button elevation', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    final button = sizedButton(DaisyButtonSize.md, DaisyButtonModifier.square);
    Material buttonMaterial() => tester.widget<Material>(
      find.descendant(of: button, matching: find.byType(Material)).first,
    );
    await tester.ensureVisible(button);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(buttonMaterial().elevation, 0);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(button));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(buttonMaterial().elevation, 1);
    await mouse.down(tester.getCenter(button));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(buttonMaterial().elevation, 0);
    await mouse.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(buttonMaterial().elevation, 1);
    await mouse.removePointer();
  });

  testWidgets('The preview fits a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    expect(find.text('Button sizes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
