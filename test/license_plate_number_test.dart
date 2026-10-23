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
      expect(() => controller.plateNumber = '沪A1234567', throwsArgumentError);
    });

    test('plateNumber can be cleared and rewritten', () {
      final controller = KeyboardController()..plateNumber = '沪A12345';
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

    test('clear() empties the plate and resets cursor', () {
      final controller = KeyboardController()..plateNumber = '沪A12345';
      controller.clear();
      expect(controller.plateNumber, '');
      expect(controller.cursorIndex, 0);
      expect(controller.characters, ['', '', '', '', '', '', '', '']);
    });

    test('characters returns a read-only copy of the plate array', () {
      final controller = KeyboardController()..plateNumber = '沪A';
      expect(controller.characters.take(2), ['沪', 'A']);
      expect(() => controller.characters.add('x'), throwsUnsupportedError);
    });
  });

  group('PlateKeyboard', () {
    testWidgets('first position shows province keys only', (tester) async {
      final controller = KeyboardController();
      final typed = <String>[];
      await tester.pumpWidget(
        _wrap(
          PlateKeyboard(
            keyboardController: controller,
            onChange: (index, value) => typed.add(value),
          ),
        ),
      );

      expect(find.text('沪'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      await tester.tap(find.text('沪'));
      await tester.pumpAndSettle();
      expect(typed, ['沪']);
      expect(controller.cursorIndex, 1);
    });

    testWidgets('number keys are disabled on second position', (tester) async {
      final controller = KeyboardController()..plateNumber = '沪';
      final typed = <String>[];
      await tester.pumpWidget(
        _wrap(
          PlateKeyboard(
            keyboardController: controller,
            onChange: (index, value) => typed.add(value),
          ),
        ),
      );

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      expect(typed, isEmpty);

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      expect(typed, ['A']);
    });

    testWidgets('backspace clears current char and moves cursor back', (
      tester,
    ) async {
      final controller = KeyboardController()..plateNumber = '沪A';
      final changes = <int, String>{};
      await tester.pumpWidget(
        _wrap(
          PlateKeyboard(
            keyboardController: controller,
            onChange: (index, value) => changes[index] = value,
          ),
        ),
      );

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

    testWidgets('province page includes military codes and no W key', (
      tester,
    ) async {
      final controller = KeyboardController();
      final typed = <String>[];
      await tester.pumpWidget(
        _wrap(
          PlateKeyboard(
            keyboardController: controller,
            onChange: (index, value) => typed.add(value),
          ),
        ),
      );

      expect(find.text('军'), findsOneWidget);
      expect(find.text('成'), findsOneWidget);
      expect(find.text('W'), findsNothing);

      await tester.tap(find.text('军'));
      await tester.pumpAndSettle();
      expect(typed, ['军']);
    });

    testWidgets('new energy slot only enables D/F letters and digits', (
      tester,
    ) async {
      final controller = KeyboardController()..plateNumber = '沪A12345';
      final typed = <String>[];
      await tester.pumpWidget(
        _wrap(
          PlateKeyboard(
            keyboardController: controller,
            onChange: (index, value) => typed.add(value),
          ),
        ),
      );
      expect(controller.cursorIndex, 7);

      // D and F are enabled.
      await tester.tap(find.text('D'));
      await tester.pumpAndSettle();
      expect(typed, ['D']);

      // Other letters are disabled.
      await tester.tap(find.text('G'));
      await tester.pumpAndSettle();
      expect(typed, ['D']);

      // Special suffixes stay visible but are disabled on the new energy slot.
      await tester.tap(find.text('学'));
      await tester.pumpAndSettle();
      expect(typed, ['D']);
      await tester.tap(find.text('临'));
      await tester.pumpAndSettle();
      expect(typed, ['D']);
    });

    testWidgets('special keys are enabled on last common position', (
      tester,
    ) async {
      final controller = KeyboardController()..plateNumber = '沪A1234';
      final typed = <String>[];
      await tester.pumpWidget(
        _wrap(
          PlateKeyboard(
            keyboardController: controller,
            onChange: (index, value) => typed.add(value),
          ),
        ),
      );
      expect(controller.cursorIndex, 6);

      await tester.tap(find.text('临'));
      await tester.pumpAndSettle();
      expect(typed, ['临']);
    });

    testWidgets('fits a small landscape surface without overflow', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(640, 360));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final controller = KeyboardController();
      await tester.pumpWidget(
        _wrap(PlateKeyboard(keyboardController: controller)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PlateKeyboard), findsOneWidget);
    });

    testWidgets('onKeyPressed reports every key including backspace', (
      tester,
    ) async {
      final controller = KeyboardController();
      final pressed = <String>[];
      await tester.pumpWidget(
        _wrap(
          PlateKeyboard(
            keyboardController: controller,
            onKeyPressed: pressed.add,
          ),
        ),
      );

      await tester.tap(find.text('沪'));
      await tester.pumpAndSettle();
      final backspace = find.descendant(
        of: find.byType(PlateKeyboard),
        matching: find.byType(Image),
      );
      await tester.tap(backspace);
      await tester.pumpAndSettle();
      expect(pressed, ['沪', '']);
    });
  });

  group('PlateInputField', () {
    testWidgets('renders plate characters and new energy placeholder', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const PlateInputField(placeHolder: '沪A12345')),
      );
      for (final ch in '沪A12345'.split('')) {
        expect(find.text(ch), findsOneWidget);
      }
      expect(find.text('新能源'), findsOneWidget);
    });

    testWidgets('auto completes after 7 chars when autoCompleteLength is 7', (
      tester,
    ) async {
      String? completed;
      await tester.pumpWidget(
        _wrap(
          PlateInputField(
            autoCompleteLength: 7,
            onCompleted: (array, value) => completed = value,
          ),
        ),
      );

      // Tap the first input field to show the keyboard on the province page.
      final firstField =
          find
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

    testWidgets('keyboard can be shown and hidden via controller', (
      tester,
    ) async {
      final controller = KeyboardController();
      await tester.pumpWidget(
        _wrap(PlateInputField(keyboardController: controller)),
      );

      controller.showKeyboard(tester.element(find.byType(PlateInputField)));
      await tester.pumpAndSettle();
      expect(controller.isKeyboardShowing(), isTrue);
      expect(find.byType(PlateKeyboard), findsOneWidget);

      controller.hideKeyboard();
      await tester.pumpAndSettle();
      expect(controller.isKeyboardShowing(), isFalse);
      expect(find.byType(PlateKeyboard), findsNothing);
    });

    testWidgets('autoCompleteLength out of 1-8 throws', (tester) async {
      expect(
        () => PlateInputField(autoCompleteLength: 9),
        throwsAssertionError,
      );
      expect(
        () => PlateInputField(autoCompleteLength: 0),
        throwsAssertionError,
      );
    });

    testWidgets('newEnergyPlaceHolder is customizable', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlateInputField(newEnergyPlaceHolder: 'NE')),
      );
      expect(find.text('NE'), findsOneWidget);
      expect(find.text('新能源'), findsNothing);
    });

    testWidgets('input field exposes a text-field semantics node', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const PlateInputField(placeHolder: '沪A')));
      expect(find.bySemanticsLabel('车牌号'), findsOneWidget);
    });

    testWidgets('dismissOnTapOutside hides the keyboard', (tester) async {
      final controller = KeyboardController();
      await tester.pumpWidget(
        _wrap(
          PlateInputField(
            keyboardController: controller,
            dismissOnTapOutside: true,
          ),
        ),
      );

      controller.showKeyboard(tester.element(find.byType(PlateInputField)));
      await tester.pumpAndSettle();
      expect(controller.isKeyboardShowing(), isTrue);

      // Tap the empty area of the input row, outside any character field.
      await tester.tapAt(const Offset(10, 27));
      await tester.pumpAndSettle();
      expect(controller.isKeyboardShowing(), isFalse);
    });
  });

  group('PlatePatterns', () {
    testWidgets('korea pattern switches between digit and hangul pages', (
      tester,
    ) async {
      final controller = KeyboardController()..pattern = PlatePatterns.korea;
      final typed = <String>[];
      await tester.pumpWidget(
        _wrap(
          PlateKeyboard(
            keyboardController: controller,
            onChange: (index, value) => typed.add(value),
          ),
        ),
      );

      // Slot 0 shows the digit page; hangul keys are absent.
      expect(find.text('1'), findsOneWidget);
      expect(find.text('가'), findsNothing);

      // Typing 1, 2, 3 moves the cursor to slot 3 (hangul page).
      for (final ch in ['1', '2', '3']) {
        await tester.tap(find.text(ch));
        await tester.pumpAndSettle();
      }
      expect(controller.cursorIndex, 3);
      expect(find.text('가'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      await tester.tap(find.text('가'));
      await tester.pumpAndSettle();
      expect(typed, ['1', '2', '3', '가']);
    });

    testWidgets('unitedStates pattern completes after 7 chars by default', (
      tester,
    ) async {
      String? completed;
      await tester.pumpWidget(
        _wrap(
          PlateInputField(
            pattern: PlatePatterns.unitedStates,
            onCompleted: (array, value) => completed = value,
          ),
        ),
      );

      // 7 slots plus one separator after slot 2.
      final row = tester.widget<Row>(
        find.descendant(
          of: find.byType(PlateInputField),
          matching: find.byType(Row),
        ),
      );
      expect(row.children.length, 8);

      final firstField =
          find
              .descendant(
                of: find.byType(PlateInputField),
                matching: find.byType(GestureDetector),
              )
              .first;
      await tester.tap(firstField);
      await tester.pumpAndSettle();

      for (final ch in 'ABC1234'.split('')) {
        await _typeKey(tester, ch);
      }
      expect(completed, 'ABC1234');
    });

    test('controller adapts when switching to a new pattern', () {
      final controller = KeyboardController();
      controller.plateNumber = '沪A12345';
      controller.pattern = PlatePatterns.unitedStates;
      expect(controller.characters.length, 7);
      expect(controller.cursorIndex, 6);
      expect(() => controller.plateNumber = 'ABCDEFGH', throwsArgumentError);
    });
  });

  group('multi-row patterns', () {
    testWidgets('japan pattern renders two rows of slots', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlateInputField(pattern: PlatePatterns.japan)),
      );
      final rows = find.descendant(
        of: find.byType(PlateInputField),
        matching: find.byType(Row),
      );
      // 11 slots in two rows: 6 + 5, no separators.
      expect(rows, findsNWidgets(2));
      expect(tester.widget<Row>(rows.at(0)).children.length, 6);
      expect(tester.widget<Row>(rows.at(1)).children.length, 5);
    });

    testWidgets('japan pattern switches pages across rows', (tester) async {
      final controller = KeyboardController()..pattern = PlatePatterns.japan;
      final typed = <String>[];
      await tester.pumpWidget(
        _wrap(
          PlateKeyboard(
            keyboardController: controller,
            onChange: (index, value) => typed.add(value),
          ),
        ),
      );

      // Slot 0: region kanji page.
      expect(find.text('品'), findsOneWidget);
      expect(find.text('あ'), findsNothing);

      // Type kanji, then digits until the hiragana slot.
      for (final ch in ['品', '川', '谷', '5', '0', '0']) {
        await tester.tap(find.text(ch));
        await tester.pumpAndSettle();
      }
      expect(controller.cursorIndex, 6);

      // Slot 6: hiragana page.
      expect(find.text('さ'), findsOneWidget);
      expect(find.text('品'), findsNothing);
      expect(find.text('1'), findsNothing);

      await tester.tap(find.text('さ'));
      await tester.pumpAndSettle();
      expect(typed, ['品', '川', '谷', '5', '0', '0', 'さ']);

      // Slot 7: back to the digit page for the serial number.
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('malformed displayRows throws ArgumentError', (tester) async {
      const bad = PlatePattern(
        code: 'BAD',
        name: 'bad',
        slots: [
          PlateSlot({'A'}),
          PlateSlot({'B'}),
        ],
        keyPages: [
          KeyPage(
            columns: 2,
            keys: ['A', 'B'],
            aspectRatioPortrait: 1,
            aspectRatioLandscape: 1,
          ),
        ],
        displayRows: [
          [0],
        ],
      );
      await tester.pumpWidget(_wrap(const PlateInputField(pattern: bad)));
      expect(tester.takeException(), isArgumentError);
    });
  });
}
