# license_plate_number

[![pub package](https://img.shields.io/pub/v/license_plate_number)](https://img.shields.io/pub/v/license_plate_number)

#### Language: [English](README.md) | [中文简体](README_CN.md) 

Flutter package for inputting chinese license plate number.

- Build-in one light style and one dark style, and the style can be changed.
- Supporting landscape.
- Plate numbers can be edited separately.

![](screenshots/screenshot_portrait.jpeg)

![](screenshots/screenshot_landscape.jpeg)



## How to use

### Install

```yaml
dependencies:
  license_plate_number: ^2.1.0
```

### Basic usage

Package includes two main widgets，`PlateInputField` and `PlateKeyboard`.

`PlateInputField` is for inputting the plate number.

```dart
Container(
  alignment: Alignment.center,
  child: PlateInputField(
    placeHolder: '沪A12345',
    styles: PlateStyles.light,
    inputFieldWidth: 40,
    inputFieldHeight: 54,
    autoCompleteLength: 7, // auto complete after 7 chars, use 8 for new energy plates
    onChanged: (List<String> array, String value) {
      // e.g.
      // array ['沪', 'A', '1', '2', '3', '4', '5']
      // value 沪A12345
    },
  ),
)
```

`PlateKeyboard` is usually not used directly. It is controlled by `PlateInputField`. But we also provide `KeyboardController` to show/hide the keyboard by yourself.

```dart
/// KeyboardController
KeyboardController _keyboardController = KeyboardController();

/// Show keyboard
_keyboardController.showKeyboard(context);

/// Hide keyboard
_keyboardController.hideKeyboard();

/// Is keyboard showing
_keyboardController.isKeyboardShowing();

/// Modify plate number
_keyboardController.plateNumber = 'XXXXXXX';

/// Clear plate number
_keyboardController.clear();

/// Read the plate characters as an array
List<String> characters = _keyboardController.characters;
```

```dart
PlateInputField(
  /// Pass KeyboardController to PlateInputField
  keyboardController: _keyboardController,
  /// Optional: complete after 7 chars for common plates
  autoCompleteLength: 7,
  /// Optional: haptic feedback on key press
  enableHapticFeedback: true,
  /// Optional: hide the keyboard when tapping outside the input fields
  dismissOnTapOutside: true,
);
```

Keyboard rules: the 8th position (new energy) only allows letters D/F and
digits; special suffix keys (学/领/警/港/澳/挂/临) are enabled on the last
position of common plates; the first page also contains military plate codes
(军/空/海/北/沈/兰/济/南/广/成).

Custom patterns: the keyboard layout and per-position rules are described by
`PlatePattern` (slots, key pages, separators). `PlatePatterns.china` is the
default; pass `pattern:` to `PlateInputField` to use another country format.


### Styles

Two default styles was build in，but self-defined style is also supported.

```dart
/// 1. Use constructor.
PlateStyles(
  /// Text style of plate input field.
  plateInputFieldTextStyle: TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 20,
    fontWeight: FontWeight.normal,
  ),
  /// Text style of new energy place holder.
  newEnergyPlaceHolderTextStyle: TextStyle(
    color: Color(0xFFDDDDDD),
    fontSize: 10,
    fontWeight: FontWeight.normal,
  ),
  /// Background color of input field.
  plateInputFieldColor: Color(0xFF4A4A4A),
  /// Border of input field.
  plateInputBorder: Border.fromBorderSide(BorderSide(
    color: Color(0xFFFFFFFF),
    width: 2,
    style: BorderStyle.solid,
  )),
  /// Border of focused input field.
  plateInputFocusedBorder: Border.fromBorderSide(BorderSide(
    color: Color(0xFF2196F3),
    width: 2,
    style: BorderStyle.solid,
  )),
  /// Border radius of input field.
  plateInputBorderRadius: const Radius.circular(8.0),
  /// Color of Separator between city code and numbers.
  plateSeparatorColor: Color(0xFFFFFFFF),
  
  /// Background color of keyboard.
  keyboardBackgroundColor: Color(0xFF131313),
  /// Text color of key text.
  keyboardButtonTextColor: Color(0xFFFFFFFF),
  /// Background color of keys.
  keyboardButtonColor: Color(0xFF4A4A4A),
  /// Background color of disabled keys.
  keyboardButtonDisabledColor: Color(0x994A4A4A),
);
```

```dart
/// 2. Copy with a default style.
PlateStyles.dark.copyWith(
  keyboardBackgroundColor: Color(0xFF000000),
);
```

