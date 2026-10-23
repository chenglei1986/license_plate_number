import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:license_plate_number/license_plate_number.dart';

void main() {
  testWidgets('example app smoke test', (tester) async {
    await tester.pumpWidget(const LicensePlateApp());
    await tester.pumpAndSettle();

    expect(find.byType(PlateInputField), findsOneWidget);
    expect(find.text('中国'), findsOneWidget);
    expect(find.text('韩国'), findsOneWidget);
    expect(find.text('美国'), findsOneWidget);
    expect(find.text('日本'), findsOneWidget);
    expect(find.text('车牌制式'), findsOneWidget);
  });
}
