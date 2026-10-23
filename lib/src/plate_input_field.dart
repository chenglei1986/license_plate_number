import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/widgets.dart';
import 'package:license_plate_number/license_plate_number.dart';

/// 车牌号输入框
class PlateInputField extends StatefulWidget {
  const PlateInputField({
    super.key,
    this.placeHolder = '',
    this.styles = PlateStyles.dark,
    this.inputFieldWidth = 40,
    this.inputFieldHeight = 54,
    this.plateSeparatorSize = 6,
    this.plateSeparatorPadding = 8,
    this.keyboardController,
    this.pattern = PlatePatterns.china,
    this.completeText = '完成',
    this.autoCompleteLength,
    this.newEnergyPlaceHolder = '新能源',
    this.semanticsLabel = '车牌号',
    this.dismissOnTapOutside = false,
    this.enableHapticFeedback = false,
    this.onChanged,
    this.onCompleted,
    this.onKeyPressed,
  }) : assert(
         autoCompleteLength == null ||
             (autoCompleteLength >= 1 && autoCompleteLength <= 8),
         'autoCompleteLength should be between 1 and 8.',
       );

  /// 车牌号
  final String placeHolder;

  /// 主题
  final PlateStyles styles;

  /// 输入框宽度
  final double inputFieldWidth;

  /// 输入框高度
  final double inputFieldHeight;

  /// 分隔符大小
  final double plateSeparatorSize;

  /// 分隔符左右间距
  final double plateSeparatorPadding;

  /// 键盘控制器
  final KeyboardController? keyboardController;

  /// 车牌模式，决定槽位数、每槽字符集与键盘布局
  final PlatePattern pattern;

  /// 键盘完成按钮文字
  final String completeText;

  /// 输入达到该长度时自动触发 [onCompleted] 并收起键盘。
  ///
  /// 取值范围 1 ~ 8，为空时等于 [pattern] 的槽位数。
  /// 中国车牌（8 槽位）默认 8，即新能源车牌输满后自动完成；
  /// 普通 7 位车牌可设为 7。
  final int? autoCompleteLength;

  /// 新能源输入框占位文字
  final String newEnergyPlaceHolder;

  /// 输入框的无障碍语义标签
  final String semanticsLabel;

  /// 是否开启键盘外（输入框空白区域）点击收起键盘。
  ///
  /// 仅覆盖输入框自身范围内的空白区域；如需点击页面任意空白处收起
  /// 键盘，请在页面层包一层 GestureDetector 调用
  /// `KeyboardController.hideKeyboard`。
  final bool dismissOnTapOutside;

  /// 按下键盘按键时是否触发触感反馈
  final bool enableHapticFeedback;

  /// 完成后的回调
  ///
  /// * [array] - 车牌号字符数组
  /// * [value] - 车牌号字符串
  final void Function(List<String> array, String value)? onCompleted;

  /// 输入变化监听器
  ///
  /// * [array] - 车牌号字符数组
  /// * [value] - 车牌号字符串
  final void Function(List<String> array, String value)? onChanged;

  /// 任意键盘按键（含退格，退格值为空字符串）被按下时的回调
  final ValueChanged<String>? onKeyPressed;

  @override
  State<PlateInputField> createState() => _PlateInputFieldState();
}

class _PlateInputFieldState extends State<PlateInputField>
    with SingleTickerProviderStateMixin {
  /// 键盘进入和退出动画控制器
  AnimationController? _controller;

  /// 键盘控制器
  late KeyboardController _keyboardController;

  @override
  void initState() {
    super.initState();
    String plateNumber = widget.placeHolder;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _keyboardController = widget.keyboardController ?? KeyboardController();
    _syncControllerConfig();
    if (widget.placeHolder.length > widget.pattern.slots.length) {
      throw ArgumentError.value(
        widget.placeHolder,
        'placeHolder',
        'Length exceeds the slot count of the pattern.',
      );
    }
    if (widget.autoCompleteLength != null &&
        widget.autoCompleteLength! > widget.pattern.slots.length) {
      throw ArgumentError.value(
        widget.autoCompleteLength,
        'autoCompleteLength',
        'Exceeds the slot count of the pattern.',
      );
    }
    final rows = widget.pattern.displayRows;
    if (rows.isNotEmpty) {
      final flattened = rows.expand((row) => row).toList()..sort();
      if (flattened.length != widget.pattern.slots.length ||
          flattened.first != 0 ||
          flattened.last != widget.pattern.slots.length - 1) {
        throw ArgumentError.value(
          widget.pattern.displayRows,
          'displayRows',
          'Must cover every slot exactly once.',
        );
      }
    }
    _keyboardController.plateNumber = plateNumber;
    _keyboardController.onPlateNumberChanged = onPlateNumberChanged;
    _keyboardController.animationController = _controller;
    if (widget.onCompleted != null) {
      _keyboardController.onComplete = widget.onCompleted!;
    }
  }

  @override
  void didUpdateWidget(PlateInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllerConfig();
  }

  /// 把 widget 配置同步到控制器（含模式切换时的键盘刷新）。
  ///
  /// 只在 initState / didUpdateWidget 中调用，避免在 build 阶段
  /// 触发悬浮窗口的 markNeedsBuild。
  void _syncControllerConfig() {
    _keyboardController
      ..pattern = widget.pattern
      ..styles = widget.styles
      ..completeText = widget.completeText
      ..enableHapticFeedback = widget.enableHapticFeedback
      ..onKeyPressed = widget.onKeyPressed;
  }

  @override
  void dispose() {
    // 先移除键盘悬浮窗口，再释放动画控制器
    _keyboardController.dispose();
    _controller!.dispose();
    super.dispose();
  }

  void onPlateNumberChanged(int index, String value) {
    final controller = _keyboardController;
    controller._plateNumbers[index] = value;
    controller._plateNumber = controller._plateNumbers.join();
    if (value.isNotEmpty) {
      controller.valueNotifier.value = controller._plateNumber;
      final completeAt =
          (widget.autoCompleteLength ?? widget.pattern.slots.length) - 1;
      if (index >= completeAt && controller.cursorIndex >= completeAt) {
        // before close the keyboard, call the complete callback
        widget.onCompleted?.call(
          controller._plateNumbers,
          controller._plateNumber,
        );
        controller.hideKeyboard();
      }
    } else {
      setState(() {});
    }
    widget.onChanged?.call(controller._plateNumbers, controller._plateNumber);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _keyboardController.keyboardShowing,
      builder: (context, showing, child) {
        return PopScope(
          canPop: !showing,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              _keyboardController.hideKeyboard();
            }
          },
          child: ValueListenableBuilder<String>(
            valueListenable: _keyboardController.valueNotifier,
            builder: (context, value, child) {
              Widget field = Semantics(
                textField: true,
                label: widget.semanticsLabel,
                value: value.isEmpty ? null : value,
                child: _buildInputFields(),
              );
              if (widget.dismissOnTapOutside) {
                field = GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (_keyboardController.isKeyboardShowing()) {
                      _keyboardController.hideKeyboard();
                    }
                  },
                  child: field,
                );
              }
              return field;
            },
          ),
        );
      },
    );
  }

  Widget _buildInputFields() {
    final pattern = widget.pattern;
    final displayRows = pattern.displayRows;
    if (displayRows.isEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildSlotsRow(List.generate(pattern.slots.length, (i) => i)),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in displayRows)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildSlotsRow(row),
          ),
      ],
    );
  }

  List<Widget> _buildSlotsRow(List<int> slotIndices) {
    final pattern = widget.pattern;
    List<Widget> children = [];
    for (final i in slotIndices) {
      children.add(_buildSingleField(_keyboardController._plateNumbers[i], i));
      if (pattern.slotSeparators.contains(i)) {
        children.add(_buildSeparator());
      }
    }
    return children;
  }

  Widget _buildSingleField(String data, int index) {
    bool focused = _keyboardController.cursorIndex == index;
    final placeholder = widget.pattern.slots[index].placeholder;
    bool hasPlaceholder = placeholder != null;
    Border commonBorder =
        focused
            ? widget.styles.plateInputFocusedBorder
            : widget.styles.plateInputBorder;
    Border border = hasPlaceholder && !focused ? const Border() : commonBorder;
    var text = FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        data.isEmpty && hasPlaceholder ? (widget.newEnergyPlaceHolder) : data,
        maxLines: 1,
        softWrap: false,
        style:
            hasPlaceholder && data.isEmpty
                ? widget.styles.newEnergyPlaceHolderTextStyle
                : widget.styles.plateInputFieldTextStyle,
      ),
    );
    var container = Container(
      width: widget.inputFieldWidth,
      height: widget.inputFieldHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.styles.plateInputFieldColor,
        border: border,
        borderRadius: BorderRadius.all(widget.styles.plateInputBorderRadius),
      ),
      child: text,
    );
    var newEnergyField = DottedBorder(
      options: RoundedRectDottedBorderOptions(
        radius: widget.styles.plateInputBorderRadius,
        color: widget.styles.newEnergyBorderColor,
        padding: const EdgeInsets.all(1),
        strokeWidth: 2,
        dashPattern: const [4, 2],
      ),
      child: container,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        child: hasPlaceholder && !focused ? newEnergyField : container,
        onTap: () {
          _keyboardController.cursorIndex = index;
          _keyboardController.showKeyboard(context);
          setState(() {});
        },
      ),
    );
  }

  Widget _buildSeparator() {
    return Container(
      width: widget.plateSeparatorSize,
      height: widget.plateSeparatorSize,
      decoration: ShapeDecoration(
        shape: const CircleBorder(),
        color: widget.styles.plateSeparatorColor,
      ),
      margin: EdgeInsets.symmetric(horizontal: widget.plateSeparatorPadding),
    );
  }
}

/// 键盘控制器
class KeyboardController {
  KeyboardController();

  /// 车牌号码数组，长度与 [pattern] 的槽位数一致
  List<String> _plateNumbers = List.filled(
    PlatePatterns.china.slots.length,
    '',
    growable: true,
  );

  /// 车牌号
  String _plateNumber = '';

  int _cursorIndex = 0;

  PlatePattern _pattern = PlatePatterns.china;

  /// 当前光标位置，取值 0 ~ 槽位数-1，越界赋值会被截断
  int get cursorIndex => _cursorIndex;

  set cursorIndex(int value) {
    final maxIndex = _pattern.slots.length - 1;
    if (value < 0) {
      _cursorIndex = 0;
    } else if (value > maxIndex) {
      _cursorIndex = maxIndex;
    } else {
      _cursorIndex = value;
    }
  }

  /// 车牌模式，决定槽位数、字符集与键盘布局
  PlatePattern get pattern => _pattern;

  set pattern(PlatePattern value) {
    if (identical(_pattern, value)) return;
    _pattern = value;
    if (_plateNumbers.length != value.slots.length) {
      final old = _plateNumbers;
      _plateNumbers = List.generate(
        value.slots.length,
        (i) => i < old.length ? old[i] : '',
      );
    }
    cursorIndex = _cursorIndex;
    _plateNumber = _plateNumbers.join();
    valueNotifier.value = _plateNumber;
    // 键盘展开时切换制式，同步刷新悬浮窗口内的键盘布局
    _keyboardOverlay?.markNeedsBuild();
  }

  /// 车牌号变化通知器
  final ValueNotifier<String> valueNotifier = ValueNotifier('');

  /// 键盘可见状态通知器
  final ValueNotifier<bool> keyboardShowing = ValueNotifier(false);

  /// 键盘完成按钮文字
  String completeText = '完成';

  /// 按下键盘按键时是否触发触感反馈
  bool enableHapticFeedback = false;

  /// 任意按键（含退格，退格值为空字符串）被按下时的回调
  ValueChanged<String>? onKeyPressed;

  /// 键盘悬浮窗口
  OverlayEntry? _keyboardOverlay;

  /// 键盘进入和退出动画控制器
  AnimationController? _controller;

  /// 主题
  PlateStyles _styles = PlateStyles.light;
  void Function(int index, String value)? _onPlateNumberChanged;
  void Function(List<String> array, String value)? _onCompleted;

  /// 设置车牌号，长度不能超过当前模式的槽位数
  set plateNumber(String plateNumber) {
    if (plateNumber.length > _plateNumbers.length) {
      throw ArgumentError.value(
        plateNumber,
        'plateNumber',
        'Length must be less than or equal to the slot count of the pattern.',
      );
    }
    _plateNumber = plateNumber;
    List<String> numbers = plateNumber.split('');
    _plateNumbers.fillRange(0, _plateNumbers.length, '');
    _plateNumbers.replaceRange(0, numbers.length, numbers);
    cursorIndex = numbers.length;
    valueNotifier.value = plateNumber;
  }

  String get plateNumber => _plateNumber;

  /// 清空车牌号
  void clear() {
    plateNumber = '';
  }

  /// 车牌号字符数组（只读副本）
  List<String> get characters => List.unmodifiable(_plateNumbers);

  set animationController(AnimationController? controller) =>
      _controller = controller;

  set styles(PlateStyles styles) {
    if (identical(_styles, styles)) return;
    _styles = styles;
    // 主题切换时同步刷新悬浮窗口内的键盘样式
    _keyboardOverlay?.markNeedsBuild();
  }

  set onPlateNumberChanged(
    void Function(int index, String value) onPlateNumberChanged,
  ) => _onPlateNumberChanged = onPlateNumberChanged;

  set onComplete(void Function(List<String> array, String value) onComplete) =>
      _onCompleted = onComplete;

  /// 显示键盘
  void showKeyboard(BuildContext context) {
    if (_keyboardOverlay != null) {
      _keyboardOverlay!.remove();
      _keyboardOverlay = null;
    }
    _keyboardOverlay = OverlayEntry(
      builder: (context) {
        return PlateKeyboard(
          plateNumbers: _plateNumbers,
          keyboardController: this,
          styles: _styles,
          newEnergy: cursorIndex == _pattern.slots.length - 1,
          completeText: completeText,
          enableHapticFeedback: enableHapticFeedback,
          onChange: _onPlateNumberChanged,
          onKeyPressed: onKeyPressed,
          animationController: _controller,
          onComplete: () {
            if (_onCompleted != null) {
              _onCompleted!(_plateNumbers, _plateNumber);
            }
            hideKeyboard();
          },
        );
      },
    );
    Overlay.of(context).insert(_keyboardOverlay!);
    if (!keyboardShowing.value) {
      keyboardShowing.value = true;
      _controller?.forward();
    }
  }

  /// 隐藏键盘
  void hideKeyboard() {
    if (!isKeyboardShowing()) {
      return;
    }
    keyboardShowing.value = false;
    final entry = _keyboardOverlay;
    final controller = _controller;
    if (controller != null && controller.value > 0) {
      // 退出动画结束后再移除悬浮窗口，避免键盘常驻内存
      controller.reverse().whenComplete(() {
        if (identical(_keyboardOverlay, entry)) {
          entry?.remove();
          _keyboardOverlay = null;
        }
      });
    } else {
      entry?.remove();
      _keyboardOverlay = null;
    }
  }

  /// 键盘是否可见
  bool isKeyboardShowing() {
    return keyboardShowing.value;
  }

  /// 移除悬浮窗口并释放资源
  void dispose() {
    _keyboardOverlay?.remove();
    _keyboardOverlay = null;
    keyboardShowing.dispose();
    valueNotifier.dispose();
  }
}
