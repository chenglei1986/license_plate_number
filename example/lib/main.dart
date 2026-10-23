import 'dart:math';

import 'package:flutter/material.dart';
import 'package:license_plate_number/license_plate_number.dart';

import 'l10n/app_localizations.dart';

void main() {
  runApp(const LicensePlateApp());
}

/// PopupMenuButton 的 onSelected 在弹出值为 null 时不触发（与取消菜单
/// 无法区分），因此「跟随系统」项用一个非空的哨兵对象作为 value。
const Object _systemDefaultValue = Object();

class LicensePlateApp extends StatefulWidget {
  const LicensePlateApp({super.key});

  @override
  State<LicensePlateApp> createState() => _LicensePlateAppState();
}

class _LicensePlateAppState extends State<LicensePlateApp> {
  Brightness _brightness = Brightness.light;
  Locale? _locale;

  void _toggleTheme() {
    setState(() {
      _brightness =
          _brightness == Brightness.light ? Brightness.dark : Brightness.light;
    });
  }

  void _setLocale(Locale? locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'License Plate',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...globalDelegates,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3450A1),
          brightness: _brightness,
        ),
      ),
      home: PlateInputPage(
        brightness: _brightness,
        onToggleTheme: _toggleTheme,
        currentLocale: _locale,
        onLocaleChanged: _setLocale,
      ),
    );
  }
}

class PlateInputPage extends StatefulWidget {
  const PlateInputPage({
    super.key,
    required this.brightness,
    required this.onToggleTheme,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  final Brightness brightness;
  final VoidCallback onToggleTheme;
  final Locale? currentLocale;
  final ValueChanged<Locale?> onLocaleChanged;

  @override
  State<PlateInputPage> createState() => _PlateInputPageState();
}

class _PlateInputPageState extends State<PlateInputPage> {
  static const _patterns = [
    PlatePatterns.china,
    PlatePatterns.korea,
    PlatePatterns.unitedStates,
    PlatePatterns.japan,
  ];

  final KeyboardController _controller = KeyboardController();
  PlatePattern _pattern = PlatePatterns.china;
  bool _haptic = true;
  bool _dismissOnTapOutside = true;

  PlateStyles get _styles =>
      widget.brightness == Brightness.dark
          ? PlateStyles.dark
          : PlateStyles.light;

  void _selectPattern(Set<PlatePattern> selection) {
    final pattern = selection.first;
    setState(() {
      _pattern = pattern;
      _controller
        ..pattern = pattern
        ..clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final inputFieldWidth = min(size.width, size.height) / 11;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        centerTitle: true,
        actions: [
          PopupMenuButton<Object>(
            tooltip: l10n.languageTooltip,
            icon: const Icon(Icons.translate),
            onSelected: (value) {
              widget.onLocaleChanged(
                value == _systemDefaultValue ? null : value as Locale,
              );
            },
            itemBuilder: (context) {
              PopupMenuItem<Object> item(Object value, String label) {
                final selected =
                    value == _systemDefaultValue
                        ? widget.currentLocale == null
                        : widget.currentLocale == value;
                return PopupMenuItem(
                  value: value,
                  child: Row(
                    children: [
                      Icon(
                        selected ? Icons.check : Icons.circle,
                        size: 16,
                        color:
                            selected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                      ),
                      const SizedBox(width: 8),
                      Text(label),
                    ],
                  ),
                );
              }

              return [
                item(_systemDefaultValue, l10n.systemDefault),
                const PopupMenuDivider(),
                for (final locale in AppLocalizations.supportedLocales)
                  item(locale, AppLocalizations.localeName(locale)),
              ];
            },
          ),
          IconButton(
            tooltip: l10n.themeTooltip,
            icon: Icon(
              widget.brightness == Brightness.light
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _dismissOnTapOutside ? _controller.hideKeyboard : null,
        child: SafeArea(
          // 键盘是悬浮层，不会压缩页面：整个页面作为一个滚动视图，
          // 键盘展开时追加底部留白，让任何控件都能滚到键盘上方操作。
          child: ValueListenableBuilder<bool>(
            valueListenable: _controller.keyboardShowing,
            builder: (context, keyboardShowing, _) {
              final bottomPadding = keyboardShowing ? size.height * 0.55 : 24.0;
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: bottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 28),
                    PlateInputField(
                      pattern: _pattern,
                      styles: _styles,
                      keyboardController: _controller,
                      inputFieldWidth: inputFieldWidth,
                      inputFieldHeight: inputFieldWidth * 4 / 3,
                      completeText: l10n.complete,
                      newEnergyPlaceHolder: l10n.newEnergy,
                      semanticsLabel: l10n.semanticsField,
                      enableHapticFeedback: _haptic,
                      dismissOnTapOutside: _dismissOnTapOutside,
                      onChanged:
                          (array, value) => debugPrint('onChanged → $value'),
                      onCompleted:
                          (array, value) => debugPrint('onCompleted → $value'),
                      onKeyPressed: (key) => debugPrint('key → $key'),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      l10n.patternSection,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<PlatePattern>(
                      showSelectedIcon: false,
                      segments: [
                        for (final pattern in _patterns)
                          ButtonSegment(
                            value: pattern,
                            label: Text(l10n.patternName(pattern.code)),
                          ),
                      ],
                      selected: {_pattern},
                      onSelectionChanged: _selectPattern,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_pattern.code} · ${l10n.slots(_pattern.slots.length)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: Text(l10n.hapticTitle),
                            subtitle: Text(l10n.hapticSubtitle),
                            value: _haptic,
                            onChanged: (v) => setState(() => _haptic = v),
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            title: Text(l10n.dismissTitle),
                            subtitle: Text(l10n.dismissSubtitle),
                            value: _dismissOnTapOutside,
                            onChanged: (v) {
                              setState(() => _dismissOnTapOutside = v);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
