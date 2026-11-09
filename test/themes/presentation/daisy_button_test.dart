import 'dart:ui' show Tristate;

import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(DaisyThemeService.initialize);
  setUp(() => DaisyThemeService.setTheme(DaisyThemes.light));

  Widget host(Widget child) => DaisyThemeScope(
    child: MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );

  Finder surface() => find
      .descendant(
        of: find.byType(DaisyButton),
        matching: find.byType(Material),
      )
      .first;

  testWidgets('type and style resolve the theme surface and foreground', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        DaisyButton(
          theme: const DaisyButtonTheme(style: DaisyButtonStyle.primary),
          onPressed: () {},
          child: const Text('Action'),
        ),
      ),
    );
    expect(
      tester.widget<Material>(surface()).color,
      DaisyThemes.light.colors.primary.base,
    );
    expect(
      DefaultTextStyle.of(tester.element(find.text('Action'))).style.color,
      DaisyThemes.light.colors.primary.content,
    );

    await tester.pumpWidget(
      host(
        DaisyButton(
          theme: const DaisyButtonTheme(
            type: DaisyButtonType.outlined,
            style: DaisyButtonStyle.error,
          ),
          onPressed: () {},
          child: const Text('Action'),
        ),
      ),
    );
    expect(tester.widget<Material>(surface()).color, Colors.transparent);
    final foreground = DefaultTextStyle.of(tester.element(find.text('Action')))
        .style
        .color!;
    final background = DaisyThemes.light.colors.base.base;
    final l1 = foreground.computeLuminance();
    final l2 = background.computeLuminance();
    expect(
      (l1 > l2 ? l1 + .05 : l2 + .05) / (l1 < l2 ? l1 + .05 : l2 + .05),
      greaterThanOrEqualTo(4.5),
    );
  });

  testWidgets('square and circle use the theme size and circle clips', (
    tester,
  ) async {
    for (final modifier in [
      DaisyButtonModifier.square,
      DaisyButtonModifier.circle,
    ]) {
      await tester.pumpWidget(
        host(
          DaisyButton(
            theme: DaisyButtonTheme(
              size: DaisyButtonSize.lg,
              modifier: modifier,
            ),
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(DaisyButton)),
        Size.square(DaisyThemes.light.size.fields.lg.toDouble()),
      );
      if (modifier == DaisyButtonModifier.circle) {
        expect(tester.widget<Material>(surface()).shape, isA<CircleBorder>());
        expect(
          tester.widget<Material>(surface()).clipBehavior,
          isNot(Clip.none),
        );
      }
    }
  });

  testWidgets('default size responds to theme changes', (tester) async {
    final larger = DaisyThemes.light.copyWith(
      size: DaisyThemes.light.size.copyWith(
        fields: DaisyThemes.light.size.fields.copyWith(base: 6),
      ),
    );
    await tester.pumpWidget(
      host(DaisyButton(onPressed: () {}, child: const Text('Action'))),
    );
    expect(tester.getSize(find.byType(DaisyButton)).height, 40);
    DaisyThemeService.setTheme(larger);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(DaisyButton)).height, 60);
  });

  testWidgets(
    'disabled button is visually distinct and does not invoke callback',
    (tester) async {
      var taps = 0;
      Widget button(bool enabled) => host(
        DaisyButton(
          enabled: enabled,
          onPressed: () => taps++,
          child: const Text('Action'),
        ),
      );
      await tester.pumpWidget(button(true));
      final enabledColor = tester.widget<Material>(surface()).color;
      await tester.pumpWidget(button(false));
      expect(tester.widget<Material>(surface()).color, isNot(enabledColor));
      await tester.tap(find.byType(DaisyButton));
      expect(taps, 0);
    },
  );

  testWidgets('button supports keyboard activation', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      host(DaisyButton(onPressed: () => taps++, child: const Text('Action'))),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('each color role uses its matching theme pair', (tester) async {
    final colors = DaisyThemes.light.colors;
    final pairs = [
      colors.neutral,
      colors.primary,
      colors.secondary,
      colors.accent,
      colors.info,
      colors.success,
      colors.warning,
      colors.error,
    ];
    for (var i = 0; i < DaisyButtonStyle.values.length; i++) {
      await tester.pumpWidget(
        host(
          DaisyButton(
            theme: DaisyButtonTheme(style: DaisyButtonStyle.values[i]),
            onPressed: () {},
            child: const Text('Action'),
          ),
        ),
      );
      expect(tester.widget<Material>(surface()).color, pairs[i].base);
      expect(
        DefaultTextStyle.of(tester.element(find.text('Action'))).style.color,
        pairs[i].content,
      );
    }
  });

  testWidgets('types apply their different surface recipes', (tester) async {
    for (final type in DaisyButtonType.values) {
      await tester.pumpWidget(
        host(
          DaisyButton(
            theme: DaisyButtonTheme(
              type: type,
              style: DaisyButtonStyle.primary,
            ),
            onPressed: () {},
            child: const Text('Action'),
          ),
        ),
      );
      final material = tester.widget<Material>(surface());
      if (type == DaisyButtonType.filled) {
        expect(material.color, DaisyThemes.light.colors.primary.base);
      } else if (type == DaisyButtonType.soft) {
        expect(material.color, isNot(Colors.transparent));
        expect(material.color, isNot(DaisyThemes.light.colors.primary.base));
      } else {
        expect(material.color, Colors.transparent);
      }
      if (type == DaisyButtonType.outlined) {
        expect(
          (material.shape! as RoundedRectangleBorder).side.color,
          DaisyThemes.light.colors.primary.base,
        );
      }
      final paints = tester.widgetList<CustomPaint>(
        find.descendant(
          of: find.byType(DaisyButton),
          matching: find.byType(CustomPaint),
        ),
      );
      if (type == DaisyButtonType.dashed) {
        expect(paints.any((paint) => paint.foregroundPainter != null), isTrue);
      }
      if (type == DaisyButtonType.link) {
        expect(
          DefaultTextStyle.of(tester.element(find.text('Action')))
              .style
              .decoration,
          TextDecoration.underline,
        );
      }
    }
  });

  testWidgets(
    'block fills available width and long press works without a tap callback',
    (tester) async {
      var presses = 0;
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 200,
            child: DaisyButton(
              theme: const DaisyButtonTheme(
                modifier: DaisyButtonModifier.block,
              ),
              onLongPress: () => presses++,
              child: const Text('Action'),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(DaisyButton)).width, 200);
      await tester.longPress(find.byType(DaisyButton));
      await tester.pumpAndSettle();
      expect(presses, 1);
    },
  );

  testWidgets('no callbacks exposes disabled semantics', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(const DaisyButton(child: Text('Action'))));
    final semantics = tester.getSemantics(find.byType(DaisyButton));
    expect(semantics.getSemanticsData().flagsCollection.isButton, isTrue);
    expect(
      semantics.getSemanticsData().flagsCollection.isEnabled,
      Tristate.isFalse,
    );
    handle.dispose();
  });

  testWidgets('active button displays a persistent active surface', (
    tester,
  ) async {
    Widget button(bool active) => host(
      DaisyButton(
        active: active,
        onPressed: () {},
        child: const Text('Action'),
      ),
    );
    await tester.pumpWidget(button(false));
    final normal = tester.widget<Material>(surface()).color;
    await tester.pumpWidget(button(true));
    expect(tester.widget<Material>(surface()).color, isNot(normal));
    await tester.tap(find.text('Action'));
    await tester.pumpAndSettle();
    expect(tester.widget<Material>(surface()).color, isNot(normal));
  });

  testWidgets('active appearance is ignored when disabled', (tester) async {
    Widget button(bool active) => host(
      DaisyButton(
        active: active,
        enabled: false,
        onPressed: () {},
        child: const Text('Action'),
      ),
    );
    await tester.pumpWidget(button(false));
    final disabled = tester.widget<Material>(surface()).color;
    await tester.pumpWidget(button(true));
    expect(tester.widget<Material>(surface()).color, disabled);
  });

  testWidgets(
    'soft and transparent variants are legible on theme base surfaces',
    (tester) async {
      for (final theme in DaisyThemes.values) {
        DaisyThemeService.setTheme(theme);
        for (final type in [
          DaisyButtonType.soft,
          DaisyButtonType.outlined,
          DaisyButtonType.dashed,
          DaisyButtonType.ghost,
          DaisyButtonType.link,
        ]) {
          for (final style in DaisyButtonStyle.values) {
            await tester.pumpWidget(
              host(
                DaisyButton(
                  theme: DaisyButtonTheme(type: type, style: style),
                  onPressed: () {},
                  child: const Text('Action'),
                ),
              ),
            );
            final surfaceColor = tester.widget<Material>(surface()).color!;
            final background = type == DaisyButtonType.soft
                ? surfaceColor
                : theme.colors.base.base;
            final foreground = DefaultTextStyle.of(
              tester.element(find.text('Action')),
            ).style.color!;
            final l1 = background.computeLuminance();
            final l2 = foreground.computeLuminance();
            final contrast =
                (l1 > l2 ? l1 + .05 : l2 + .05) /
                (l1 < l2 ? l1 + .05 : l2 + .05);
            expect(
              contrast,
              greaterThanOrEqualTo(4.5),
              reason: '${theme.id} ${type.name} ${style.name}',
            );
          }
        }
      }
    },
  );
}
