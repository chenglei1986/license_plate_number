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
