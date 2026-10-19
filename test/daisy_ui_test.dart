import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => DaisyThemeService.setTheme(DaisyThemes.light));
  tearDown(() => DaisyThemeService.setTheme(DaisyThemes.light));

  testWidgets('Public package API propagates theme changes', (tester) async {
    await tester.pumpWidget(
      DaisyThemeScope(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) => Text(context.daisyTheme.name),
          ),
        ),
      ),
    );

    expect(find.text('Light'), findsOneWidget);

    DaisyThemeService.setTheme(DaisyThemes.dark);
    await tester.pump();

    expect(find.text('Dark'), findsOneWidget);
  });
}
