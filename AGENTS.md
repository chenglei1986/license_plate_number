# AGENTS.md

This file provides working guidelines for AI coding assistants in this repository.

## Project Overview

`license_plate_number` is an open-source Flutter package published on [pub.dev](https://pub.dev/packages/license_plate_number) for **inputting Chinese license plate numbers**. Current version 2.1.0, migrated to null safety.

Core features:

- Built-in light / dark themes, customizable styles
- Built-in native-like plate input keyboard (custom keyboard, not the system IME)
- Supports portrait and landscape layouts
- Supports common plates (7 characters) and new energy plates (8 characters)
- New energy 8th position restricted to D/F letters per GA36 (digits stay enabled for large new energy plates)
- Military plate first-position codes (军/空/海/北/沈/兰/济/南/广/成) and the 临 suffix key
- Optional haptic feedback and key press scale animation
- Plate numbers can be edited and deleted character by character

## Tech Stack

- **Language**: Dart (SDK `^3.7.2`, null safety)
- **Framework**: Flutter (depends only on the Flutter SDK + `dotted_border ^3.1.0`)
- **Testing**: `flutter_test`
- **Repository**: GitHub [chenglei1986/license_plate_number](https://github.com/chenglei1986/license_plate_number)

## Directory Structure

```
lib/
  license_plate_number.dart    # Package entry, exports only 4 public API files
  src/
    plate_input_field.dart     # PlateInputField: plate input field + KeyboardController
    plate_keyboard.dart        # PlateKeyboard: data-driven custom plate keyboard
    plate_patterns.dart        # PlatePattern/PlateSlot/KeyPage: pattern data model + PlatePatterns.china
    plate_styles.dart          # PlateStyles: light/dark theme styles
    keyboard_button.dart       # Single key widget
    constants.dart             # CN plate key inventory (provinces, military codes, letters, suffixes)
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

- The package entry `lib/license_plate_number.dart` exports exactly four files: `plate_input_field.dart`, `plate_keyboard.dart`, `plate_patterns.dart`, `plate_styles.dart`.
- New public APIs must be exported through this entry; internal implementations (`keyboard_button.dart`, `constants.dart`, etc.) stay private and must not be exposed.
- The two main widgets work together:
  - `PlateInputField`: renders the plate input field, manages keyboard show/hide animations;
  - `PlateKeyboard`: the actual keyboard, sharing state with the input field via `KeyboardController`.
- All country-specific rules live in `PlatePatterns` data (see `plate_patterns.dart`). The China pattern (`PlatePatterns.china`) is the default; adding a new country in the future means adding a new `PlatePattern` instance, not new code branches. Never reintroduce `if (index == ...)` style branching in the keyboard rendering.
- Built-in patterns today: `china` (default), `korea`, `unitedStates`, `japan` (two-row). Known gap to keep in mind for future phases: variable-length slots (e.g. German district codes 1-3 letters) are not supported by the fixed-slot model yet.

## Domain Rules (Read Before Modifying)

Strictly follow these rules when touching plate business logic; do not "fix" them casually:

1. **Plate length**: common plates have 7 characters, new energy plates have 8 (the 8th is a letter such as D/F). There is an assertion `placeHolder.length <= 8`.
2. **The 1st character must be a province abbreviation** (京, 沪, 粤..., see the `provinces` list in `constants.dart`); the keyboard shows only province keys for the first position.
3. **The 2nd character is the issuing authority letter**.
4. **Letters I and O are not used** (easily confused with digits 1 and 0); they are excluded from the letter key layout.
5. Key layouts (province page / alphanumeric page) are defined by the constant arrays in `constants.dart`; portrait and landscape are distinguished via `childAspectRatio`.
6. The 8th position (index 7, new energy) only enables letters **D/F** plus all digits; special suffix keys (学/领/警/港/澳/挂/临) are enabled only at index 6 (the last position of common plates) and stay visible-but-disabled elsewhere.
7. The first page also contains military plate codes from `militaryCodes`. The stray 'W' key was removed; 武警 WJ two-letter prefixes are NOT supported (would require a different input pattern).
8. Code comments are written in **Chinese**; keep new code consistent.

## Code Style

- `analysis_options.yaml` includes `flutter_lints`; keep zero warnings under `flutter analyze`.
- Follow the official Flutter widget code organization: `const` constructors, private `State` classes, paired `initState`/`dispose` resource management (e.g. `AnimationController`, `ValueNotifier`).
- Keep the package **lightweight**: new dependencies need strong justification; prefer capabilities from the Flutter SDK.

## Testing Status

`test/license_plate_number_test.dart` covers `KeyboardController` rules (length validation, cursor clamping) and keyboard interactions (province page, disabled keys, backspace, auto-complete, show/hide). When modifying business logic, add or update tests accordingly; for UI changes, also verify manually in the `example` app in both orientations.

## Other Notes

- `README.md` (English) and `README_CN.md` (Chinese) must be kept in sync; user-visible behavior changes (new parameters, breaking changes) require updating both files plus `CHANGELOG.md`.
- `CHANGELOG.md` is ordered newest first: the latest version entry stays at the top.
- **Never release on your own**: do not bump version numbers, add release entries, run `flutter pub publish`, or create git tags unless the user explicitly asks.
- Version bumps follow semantic versioning and are recorded in `CHANGELOG.md`.
