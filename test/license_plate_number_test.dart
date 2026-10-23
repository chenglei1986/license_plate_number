import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:license_plate_number/license_plate_number.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

Future<void> _typeKey(WidgetTester tester, String text) async {
  final key = find.descendant(
    of: find.byType(PlateKeyboard),
    matching: find.text(text),
  );
  expect(key, findsOneWidget, reason: 'keyboard key $text not found');
  await tester.tap(key);
  await tester.pumpAndSettle();
}

void main() {
  group('KeyboardController', () {
    test('plateNumber setter splits characters and moves cursor', () {
      final controller = KeyboardController();
      controller.plateNumber = '沪A12345';
      expect(controller.plateNumber, '沪A12345');
      expect(controller.cursorIndex, 7);
    });

    test('plateNumber longer than 8 throws ArgumentError', () {
      final controller = KeyboardController();
      expect(
        () => controller.plateNumber = '沪A1234567',
        throwsArgumentError,
      );
    });

    test('plateNumber can be cleared and rewritten', () {
      final controller = KeyboardController()
        ..plateNumber = '沪A12345';
      controller.plateNumber = '粤B';
      expect(controller.plateNumber, '粤B');
      expect(controller.cursorIndex, 2);
    });

    test('cursorIndex is clamped to 0-7', () {
      final controller = KeyboardController();
      controller.cursorIndex = 99;
      expect(controller.cursorIndex, 7);
      controller.cursorIndex = -3;
      expect(controller.cursorIndex, 0);
    });

    test('keyboardShowing defaults to false', () {
      expect(KeyboardController().isKeyboardShowing(), isFalse);
    });
  });

  group('PlateKeyboard', () {
    testWidgets('first position shows province keys only', (tester) async {
      final controller = KeyboardController();
      final typed = <String>[];
      await tester.pumpWidget(_wrap(PlateKeyboard(
        keyboardController: controller,
        onChange: (index, value) => typed.add(value),
      )));

      expect(find.text('沪'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      await tester.tap(find.text('沪'));
      await tester.pumpAndSettle();
      expect(typed, ['沪']);
      expect(controller.cursorIndex, 1);
    });

    testWidgets('number keys are disabled on second position',
        (tester) async {
      final controller = KeyboardController()..plateNumber = '沪';
      final typed = <String>[];
      await tester.pumpWidget(_wrap(PlateKeyboard(
        keyboardController: controller,
        onChange: (index, value) => typed.add(value),
      )));

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      expect(typed, isEmpty);

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      expect(typed, ['A']);
    });

    testWidgets('backspace clears current char and moves cursor back',
        (tester) async {
      final controller = KeyboardController()..plateNumber = '沪A';
      final changes = <int, String>{};
      await tester.pumpWidget(_wrap(PlateKeyboard(
        keyboardController: controller,
        onChange: (index, value) => changes[index] = value,
      )));

      // Tap the backspace image button.
      final backspace = find.descendant(
        of: find.byType(PlateKeyboard),
        matching: find.byType(Image),
      );
      await tester.tap(backspace);
      await tester.pumpAndSettle();
      expect(changes, {2: ''});
      expect(controller.cursorIndex, 1);
    });
  });

  group('PlateInputField', () {
    testWidgets('renders plate characters and new energy placeholder',
        (tester) async {
      await tester.pumpWidget(
          _wrap(const PlateInputField(placeHolder: '沪A12345')));
      for (final ch in '沪A12345'.split('')) {
        expect(find.text(ch), findsOneWidget);
      }
      expect(find.text('新能源'), findsOneWidget);
    });

    testWidgets('auto completes after 7 chars when autoCompleteLength is 7',
        (tester) async {
      String? completed;
      await tester.pumpWidget(_wrap(PlateInputField(
        autoCompleteLength: 7,
        onCompleted: (array, value) => completed = value,
      )));

      // Tap the first input field to show the keyboard on the province page.
      final firstField = find
          .descendant(
            of: find.byType(PlateInputField),
            matching: find.byType(GestureDetector),
          )
          .first;
      await tester.tap(firstField);
      await tester.pumpAndSettle();
      expect(find.byType(PlateKeyboard), findsOneWidget);

      for (final ch in '沪A12345'.split('')) {
        await _typeKey(tester, ch);
      }

      expect(completed, '沪A12345');
      await tester.pumpAndSettle();
      expect(find.byType(PlateKeyboard), findsNothing);
    });

    testWidgets('keyboard can be shown and hidden via controller',
        (tester) async {
      final controller = KeyboardController();
      await tester.pumpWidget(_wrap(PlateInputField(
        keyboardController: controller,
      )));

      controller.showKeyboard(tester.element(find.byType(PlateInputField)));
      await tester.pumpAndSettle();
      expect(controller.isKeyboardShowing(), isTrue);
      expect(find.byType(PlateKeyboard), findsOneWidget);

      controller.hideKeyboard();
      await tester.pumpAndSettle();
      expect(controller.isKeyboardShowing(), isFalse);
      expect(find.byType(PlateKeyboard), findsNothing);
    });
  });
}
