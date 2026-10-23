## 2.1.0

- Fix a resource leak: `AnimationController` was not disposed in `PlateInputField`.
- Migrate from the deprecated `WillPopScope` to `PopScope`.
- Add `autoCompleteLength` to `PlateInputField`: auto complete and close the keyboard after the given length (7 for common plates, 8 for new energy plates).
- Add `completeText` to `PlateInputField` to customize the complete button label.
- Add `completeButtonTextColor` and `newEnergyBorderColor` to `PlateStyles`.
- Validate `KeyboardController.plateNumber` (throws `ArgumentError` when longer than 8) and clamp `cursorIndex` to 0-7.
- Fix the documented standalone usage of `KeyboardController.showKeyboard` without an `AnimationController`.
- Remove the keyboard overlay entry after the exit animation.
- Add `Semantics` to keyboard keys.
- Restrict the 8th position (new energy) letters to D/F per GA36; digits stay enabled for large new energy plates.
- Add military plate first-position codes (军/空/海/北/沈/兰/济/南/广/成) and the 临 suffix key; remove the invalid 'W' province key (武警 WJ two-letter prefixes are not supported).
- Add `newEnergyPlaceHolder`, `semanticsLabel`, `dismissOnTapOutside`, `enableHapticFeedback` and `onKeyPressed` to `PlateInputField`.
- Add haptic feedback (opt-in) and a key press scale animation to keyboard keys.
- Add `clear()` and `characters` to `KeyboardController`.
- Make `keyboardController` a required parameter of `PlateKeyboard`.
- Add pubspec topics, issue tracker and screenshots; grow tests to 22 cases.
- Introduce the `PlatePattern` data model (`PlateSlot` / `KeyPage` / `PlatePatterns`): slot character sets, key pages and separators are now data-driven; the built-in `PlatePatterns.china` reproduces the previous hardcoded behavior and all existing tests pass unchanged.
- Add `PlatePatterns.korea` (123가4567, hangul key page) and `PlatePatterns.unitedStates` (generic 3+4 lenient mode) to validate the pattern abstraction; `autoCompleteLength` now defaults to the pattern's slot count.
- Align the built-in patterns with local regulations (verified against MOLIT/KOTI, the Japanese 自動車登録規則/JAF and AAMVA/state DMV sources): Korea now uses the correct private-car hangul set (24 letters ending 구누두루무, replacing the incorrect 버서어저); Japan uses the 42 hiragana actually issued (お・し・へ・ん are never used) and adds the 2018 rule allowing letters A/C/F/H/K/L/M/P/X/Y in the lower two classification-number positions.
- Support multi-row plate display via `PlatePattern.displayRows` and add `PlatePatterns.japan` (two-row layout) as the validating case; malformed row groupings are rejected with an ArgumentError.
- Fix the backspace key drifting with the key count: it is now pinned to the bottom-right cell of every key page.
- Fix the keyboard not refreshing when the pattern or theme changes while it is open.
- Cap the keyboard height to half the screen and flatten keys automatically, so landscape no longer covers the input field; the new energy placeholder now renders on a single line.
- Fix a crash when the field's configuration changes (e.g. a theme toggle) while the keyboard overlay is mounted: the controller sync now runs after the frame.
- Redesign the example app (Material 3, pattern switcher, option switches) and refresh screenshots.
- Add in-app language switching (zh/en/ko/ja) to the example app and publish bilingual screenshots (Chinese and English UI) for both READMEs.
- Add `flutter_lints`, CI workflow and widget tests.

## 2.0.1

- Fix [issue #3](https://github.com/chenglei1986/license_plate_number/issues/3)

## 2.0.0

- Migrate to null safety.

## 1.1.0

- Add complete button.

## 1.0.4

- Fix a bug.

## 1.0.3

- Supporting plate number of new energy car.

## 1.0.2

- Add documents.

## 1.0.0

- Initial release.
