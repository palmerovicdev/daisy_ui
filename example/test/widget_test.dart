import 'package:daisy_ui/themes/presentation/action/button.dart';
import 'package:daisy_ui_example/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
    expect(buttonMaterial().elevation, 4);

    await mouse.down(tester.getCenter(button));
    await tester.pumpAndSettle();
    expect(buttonMaterial().elevation, 0);

    await mouse.up();
    await tester.pumpAndSettle();
    expect(buttonMaterial().elevation, 4);
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
