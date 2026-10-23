import 'dart:math';

import 'package:flutter/material.dart';
import 'package:license_plate_number/license_plate_number.dart';

void main() {
  runApp(const LicensePlateApp());
}

class LicensePlateApp extends StatefulWidget {
  const LicensePlateApp({super.key});

  @override
  State<LicensePlateApp> createState() => _LicensePlateAppState();
}

class _LicensePlateAppState extends State<LicensePlateApp> {
  Brightness _brightness = Brightness.light;

  void _toggleTheme() {
    setState(() {
      _brightness =
          _brightness == Brightness.light ? Brightness.dark : Brightness.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '车牌输入',
      debugShowCheckedModeBanner: false,
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
      ),
    );
  }
}

class PlateInputPage extends StatefulWidget {
  const PlateInputPage({
    super.key,
    required this.brightness,
    required this.onToggleTheme,
  });

  final Brightness brightness;
  final VoidCallback onToggleTheme;

  @override
  State<PlateInputPage> createState() => _PlateInputPageState();
}

class _PlateInputPageState extends State<PlateInputPage> {
  final KeyboardController _controller = KeyboardController();
  PlatePattern _pattern = PlatePatterns.china;
  bool _haptic = true;
  bool _dismissOnTapOutside = true;
  String _lastEvent = '等待输入…';
  String _lastKey = '—';

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
      _lastEvent = '已切换到 ${pattern.name}';
    });
  }

  void _log(String event) {
    setState(() => _lastEvent = event);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final inputFieldWidth = min(size.width, size.height) / 11;
    return Scaffold(
      appBar: AppBar(
        title: const Text('车牌输入'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: '切换主题',
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
          child: Column(
            children: [
              const SizedBox(height: 28),
              PlateInputField(
                pattern: _pattern,
                styles: _styles,
                keyboardController: _controller,
                inputFieldWidth: inputFieldWidth,
                inputFieldHeight: inputFieldWidth * 4 / 3,
                enableHapticFeedback: _haptic,
                dismissOnTapOutside: _dismissOnTapOutside,
                onChanged: (array, value) => _log('onChanged → $value'),
                onCompleted: (array, value) => _log('onCompleted → $value'),
                onKeyPressed: (key) {
                  setState(() => _lastKey = key.isEmpty ? '退格' : key);
                },
              ),
              const SizedBox(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ResultCard(controller: _controller),
                      const SizedBox(height: 24),
                      Text('车牌制式', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      SegmentedButton<PlatePattern>(
                        segments: const [
                          ButtonSegment(
                            value: PlatePatterns.china,
                            label: Text('中国'),
                          ),
                          ButtonSegment(
                            value: PlatePatterns.korea,
                            label: Text('韩国'),
                          ),
                          ButtonSegment(
                            value: PlatePatterns.unitedStates,
                            label: Text('美国'),
                          ),
                          ButtonSegment(
                            value: PlatePatterns.japan,
                            label: Text('日本'),
                          ),
                        ],
                        selected: {_pattern},
                        onSelectionChanged: _selectPattern,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_pattern.code} · ${_pattern.slots.length} 位',
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
                              title: const Text('触感反馈'),
                              subtitle: const Text('按下按键时振动'),
                              value: _haptic,
                              onChanged: (v) => setState(() => _haptic = v),
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              title: const Text('点击空白收起键盘'),
                              subtitle: const Text('点击输入框空白区域时'),
                              value: _dismissOnTapOutside,
                              onChanged: (v) {
                                setState(() => _dismissOnTapOutside = v);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('事件', style: theme.textTheme.titleSmall),
                              const SizedBox(height: 8),
                              Text(
                                _lastEvent,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '最后按键：$_lastKey',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 实时展示当前输入的车牌号
class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.controller});

  final KeyboardController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: ValueListenableBuilder<String>(
          valueListenable: controller.valueNotifier,
          builder: (context, value, child) {
            final empty = value.isEmpty;
            return Column(
              children: [
                Text(
                  empty ? '点击上方输入框开始' : value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                    color:
                        empty
                            ? theme.colorScheme.outline
                            : theme.colorScheme.onSurface,
                  ),
                ),
                if (!empty) ...[
                  const SizedBox(height: 6),
                  Text(
                    controller.characters.join(' '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
