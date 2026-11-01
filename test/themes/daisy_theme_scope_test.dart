import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  setUp(() => DaisyThemeService.setTheme(DaisyThemes.light));
  tearDown(() => DaisyThemeService.setTheme(DaisyThemes.light));

  testWidgets('A SignalBuilder can observe a theme controller directly', (
    tester,
  ) async {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SignalBuilder(
          builder: (context) => Text(controller.theme.value.name),
        ),
      ),
    );

    expect(find.text('Light'), findsOneWidget);
    controller.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(find.text('Dark'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Nested scopes update only their own theme consumers', (
    tester,
  ) async {
    final preview = DaisyThemeController(initialTheme: DaisyThemes.dark);
    final nested = DaisyThemeController(initialTheme: DaisyThemes.cupcake);
    addTearDown(preview.dispose);
    addTearDown(nested.dispose);
    final builds = <String, int>{'global': 0, 'preview': 0, 'nested': 0};

    Widget consumer(String label) => Builder(
      builder: (context) {
        builds[label] = builds[label]! + 1;
        return Text('$label:${context.daisyTheme.id}');
      },
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DaisyThemeScope(
          child: Column(
            children: [
              consumer('global'),
              DaisyThemeScope(
                controller: preview,
                child: Column(
                  children: [
                    consumer('preview'),
                    DaisyThemeScope(
                      controller: nested,
                      child: consumer('nested'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('global:light'), findsOneWidget);
    expect(find.text('preview:dark'), findsOneWidget);
    expect(find.text('nested:cupcake'), findsOneWidget);

    DaisyThemeService.setTheme(DaisyThemes.cupcake);
    await tester.pump();
    expect(find.text('global:cupcake'), findsOneWidget);
    expect(builds, {'global': 2, 'preview': 1, 'nested': 1});

    preview.setTheme(DaisyThemes.light);
    await tester.pump();
    expect(find.text('preview:light'), findsOneWidget);
    expect(builds, {'global': 2, 'preview': 2, 'nested': 1});

    nested.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(find.text('nested:dark'), findsOneWidget);
    expect(builds, {'global': 2, 'preview': 2, 'nested': 2});

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Replacing a controller detaches the previous notifier', (
    tester,
  ) async {
    final first = DaisyThemeController();
    final second = DaisyThemeController(initialTheme: DaisyThemes.dark);
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    var builds = 0;
    final child = Builder(
      builder: (context) {
        builds++;
        return Text(context.daisyTheme.name);
      },
    );

    Widget host(DaisyThemeController controller) => Directionality(
      textDirection: TextDirection.ltr,
      child: DaisyThemeScope(controller: controller, child: child),
    );

    await tester.pumpWidget(host(first));
    expect(find.text('Light'), findsOneWidget);
    await tester.pumpWidget(host(second));
    expect(find.text('Dark'), findsOneWidget);
    expect(builds, 2);

    first.setTheme(DaisyThemes.cupcake);
    await tester.pump();
    expect(builds, 2);

    second.setTheme(DaisyThemes.cupcake);
    await tester.pump();
    expect(find.text('Cupcake'), findsOneWidget);
    expect(builds, 3);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Unmounting a scope does not dispose its borrowed controller', (
    tester,
  ) async {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);

    Widget host() => Directionality(
      textDirection: TextDirection.ltr,
      child: DaisyThemeScope(
        controller: controller,
        child: Builder(builder: (context) => Text(context.daisyTheme.name)),
      ),
    );

    await tester.pumpWidget(host());
    await tester.pumpWidget(const SizedBox.shrink());
    controller.setTheme(DaisyThemes.dark);
    await tester.pumpWidget(host());
    expect(find.text('Dark'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Reading outside a scope reports the missing ancestor', (
    tester,
  ) async {
    await tester.pumpWidget(
      Builder(builder: (context) => Text(context.daisyTheme.name)),
    );
    expect(tester.takeException(), isA<FlutterError>());
  });
}
