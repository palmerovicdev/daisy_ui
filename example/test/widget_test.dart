import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daisy_ui_example/main.dart';

void main() {
  setUp(() => DaisyThemeService.setTheme(DaisyThemes.light));
  tearDown(() => DaisyThemeService.setTheme(DaisyThemes.light));

  testWidgets('Switches the displayed theme and surface color', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Light'), findsOneWidget);
    await tester.tap(find.text('Switch theme'));
    await tester.pump();

    expect(find.text('Dark'), findsOneWidget);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      DaisyThemes.dark.colors.base.base,
    );

    await tester.tap(find.text('Switch theme'));
    await tester.pump();
    expect(find.text('Light'), findsOneWidget);
  });

  testWidgets('Preview and application themes change independently', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Preview: Cupcake'), findsOneWidget);

    await tester.tap(find.text('Switch preview theme'));
    await tester.pump();
    expect(find.text('Preview: Dark'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);

    await tester.tap(find.text('Switch theme'));
    await tester.pump();
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Preview: Dark'), findsOneWidget);

    await tester.tap(find.text('Switch preview theme'));
    await tester.pump();
    expect(find.text('Preview: Cupcake'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
  });
}
