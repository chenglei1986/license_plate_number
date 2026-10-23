# AGENTS.md

This file provides working guidelines for AI coding assistants in this repository.

## Project Overview

`license_plate_number` is an open-source Flutter package published on [pub.dev](https://pub.dev/packages/license_plate_number) for **inputting Chinese license plate numbers**. Current version 2.1.0, migrated to null safety.

Core features:

- Built-in light / dark themes, customizable styles
- Built-in native-like plate input keyboard (custom keyboard, not the system IME)
- Supports portrait and landscape layouts
- Supports common plates (7 characters) and new energy plates (8 characters)
- Plate numbers can be edited and deleted character by character

## Tech Stack

- **Language**: Dart (SDK `^3.7.2`, null safety)
- **Framework**: Flutter (depends only on the Flutter SDK + `dotted_border ^3.1.0`)
- **Testing**: `flutter_test`
- **Repository**: GitHub [chenglei1986/license_plate_number](https://github.com/chenglei1986/license_plate_number)

## Directory Structure

```
lib/
  license_plate_number.dart    # Package entry, exports only 3 public API files
  src/
    plate_input_field.dart     # PlateInputField: plate input field + KeyboardController
    plate_keyboard.dart        # PlateKeyboard: custom plate keyboard
    plate_styles.dart          # PlateStyles: light/dark theme styles
    keyboard_button.dart       # Single key widget
    constants.dart             # Province abbreviations, digits, letter layout constants
example/                       # Demo app (for manual verification)
test/                          # Widget and unit tests
.github/workflows/             # CI (flutter analyze + flutter test)
screenshots/                   # Screenshots for README
images/                        # Image assets bundled with the package (declared in pubspec.yaml)
```

## Common Commands

```bash
flutter pub get              # Install dependencies
flutter analyze              # Static analysis (must pass before committing)
flutter test                 # Run tests
cd example && flutter run    # Run the demo app for manual UI verification
```

Publishing (maintainers only):

```bash
flutter pub publish --dry-run   # Pre-publish checks
```

## Public API Conventions

- The package entry `lib/license_plate_number.dart` exports exactly three files: `plate_input_field.dart`, `plate_keyboard.dart`, `plate_styles.dart`.
- New public APIs must be exported through this entry; internal implementations (`keyboard_button.dart`, `constants.dart`, etc.) stay private and must not be exposed.
- The two main widgets work together:
  - `PlateInputField`: renders the plate input field, manages keyboard show/hide animations;
  - `PlateKeyboard`: the actual keyboard, sharing state with the input field via `KeyboardController`.

## Domain Rules (Read Before Modifying)

Strictly follow these rules when touching plate business logic; do not "fix" them casually:

1. **Plate length**: common plates have 7 characters, new energy plates have 8 (the 8th is a letter such as D/F). There is an assertion `placeHolder.length <= 8`.
2. **The 1st character must be a province abbreviation** (京, 沪, 粤..., see the `provinces` list in `constants.dart`); the keyboard shows only province keys for the first position.
3. **The 2nd character is the issuing authority letter**.
4. **Letters I and O are not used** (easily confused with digits 1 and 0); they are excluded from the letter key layout.
5. Key layouts (province page / alphanumeric page) are defined by the constant arrays in `constants.dart`; portrait and landscape are distinguished via `childAspectRatio`.
6. Code comments are written in **Chinese**; keep new code consistent.

## Code Style

- `analysis_options.yaml` includes `flutter_lints`; keep zero warnings under `flutter analyze`.
- Follow the official Flutter widget code organization: `const` constructors, private `State` classes, paired `initState`/`dispose` resource management (e.g. `AnimationController`, `ValueNotifier`).
- Keep the package **lightweight**: new dependencies need strong justification; prefer capabilities from the Flutter SDK.

## Testing Status

`test/license_plate_number_test.dart` covers `KeyboardController` rules (length validation, cursor clamping) and keyboard interactions (province page, disabled keys, backspace, auto-complete, show/hide). When modifying business logic, add or update tests accordingly; for UI changes, also verify manually in the `example` app in both orientations.

## Other Notes

- `README.md` (English) and `README_CN.md` (Chinese) must be kept in sync; user-visible behavior changes (new parameters, breaking changes) require updating both files plus `CHANGELOG.md`.
- Version bumps follow semantic versioning and are recorded in `CHANGELOG.md`.
