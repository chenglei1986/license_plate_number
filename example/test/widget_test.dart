import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:license_plate_number/license_plate_number.dart';

void main() {
  testWidgets('example app smoke test with language switching', (tester) async {
    // The test environment defaults to en_US.
    await tester.pumpWidget(const LicensePlateApp());
    await tester.pumpAndSettle();

    expect(find.byType(PlateInputField), findsOneWidget);
    expect(find.text('License Plate'), findsOneWidget);
    expect(find.text('China'), findsOneWidget);
    expect(find.text('Korea'), findsOneWidget);
    expect(find.text('US'), findsOneWidget);
    expect(find.text('Japan'), findsOneWidget);
    expect(find.text('Plate format'), findsOneWidget);

    // Switch to Chinese via the language menu.
    await tester.tap(find.byIcon(Icons.translate));
    await tester.pumpAndSettle();
    await tester.tap(find.text('中文'));
    await tester.pumpAndSettle();

    expect(find.text('中国'), findsOneWidget);
    expect(find.text('车牌制式'), findsOneWidget);

    // Switch back to the system default (en_US in tests).
    await tester.tap(find.byIcon(Icons.translate));
    await tester.pumpAndSettle();
    await tester.tap(find.text('跟随系统'));
    await tester.pumpAndSettle();

    expect(find.text('China'), findsOneWidget);
    expect(find.text('Plate format'), findsOneWidget);
  });
}
