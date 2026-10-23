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
    this.completeText = '完成',
    this.autoCompleteLength = 8,
    this.onChanged,
    this.onCompleted,
  }) : assert(
         placeHolder.length <= 8,
         'plateNumber\'s length should be less than 8.',
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

  /// 键盘完成按钮文字
  final String completeText;

  /// 输入达到该长度时自动触发 [onCompleted] 并收起键盘。
  ///
  /// 取值范围 1 ~ 8。默认 8，即新能源车牌（8 位）输满后自动完成；
  /// 普通 7 位车牌可设为 7。
  final int autoCompleteLength;

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
    _keyboardController.plateNumber = plateNumber;
    _keyboardController.onPlateNumberChanged = onPlateNumberChanged;
    _keyboardController.animationController = _controller;
    if (widget.onCompleted != null) {
      _keyboardController.onComplete = widget.onCompleted!;
    }
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
      final completeAt = widget.autoCompleteLength - 1;
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
    _keyboardController
      ..styles = widget.styles
      ..completeText = widget.completeText;
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
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildInputFields(),
              );
            },
          ),
        );
      },
    );
  }

  List<Widget> _buildInputFields() {
    List<Widget> children = [];
    for (int i = 0; i < _keyboardController._plateNumbers.length; i++) {
      children.add(_buildSingleField(_keyboardController._plateNumbers[i], i));
      if (1 == i) {
        children.add(_buildSeparator());
      }
    }
    return children;
  }

  Widget _buildSingleField(String data, int index) {
    bool focused = _keyboardController.cursorIndex == index;
    bool newEnergy = index == 7;
    Border commonBorder =
        focused
            ? widget.styles.plateInputFocusedBorder
            : widget.styles.plateInputBorder;
    Border border = newEnergy && !focused ? const Border() : commonBorder;
    var text = Text(
      data.isEmpty && newEnergy ? '新能源' : data,
      style:
          newEnergy && data.isEmpty
              ? widget.styles.newEnergyPlaceHolderTextStyle
              : widget.styles.plateInputFieldTextStyle,
    );
    var container = Container(
      width:
          newEnergy && !focused
              ? widget.inputFieldWidth - 4
              : widget.inputFieldWidth,
      height:
          newEnergy && !focused
              ? widget.inputFieldHeight - 4
              : widget.inputFieldHeight,
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
      padding: EdgeInsets.symmetric(horizontal: newEnergy && !focused ? 3 : 2),
      child: GestureDetector(
        child: newEnergy && !focused ? newEnergyField : container,
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

  /// 车牌号码数组
  final List<String> _plateNumbers = ['', '', '', '', '', '', '', ''];

  /// 车牌号
  String _plateNumber = '';

  int _cursorIndex = 0;

  /// 当前光标位置，取值 0 ~ 7，越界赋值会被截断
  int get cursorIndex => _cursorIndex;

  set cursorIndex(int value) {
    if (value < 0) {
      _cursorIndex = 0;
    } else if (value > 7) {
      _cursorIndex = 7;
    } else {
      _cursorIndex = value;
    }
  }

  /// 车牌号变化通知器
  final ValueNotifier<String> valueNotifier = ValueNotifier('');

  /// 键盘可见状态通知器
  final ValueNotifier<bool> keyboardShowing = ValueNotifier(false);

  /// 键盘完成按钮文字
  String completeText = '完成';

  /// 键盘悬浮窗口
  OverlayEntry? _keyboardOverlay;

  /// 键盘进入和退出动画控制器
  AnimationController? _controller;

  /// 主题
  PlateStyles _styles = PlateStyles.light;
  void Function(int index, String value)? _onPlateNumberChanged;
  void Function(List<String> array, String value)? _onCompleted;

  /// 设置车牌号，长度不能超过 8 位
  set plateNumber(String plateNumber) {
    if (plateNumber.length > 8) {
      throw ArgumentError.value(
        plateNumber,
        'plateNumber',
        'Length must be less than or equal to 8.',
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

  set animationController(AnimationController? controller) =>
      _controller = controller;

  set styles(PlateStyles styles) => _styles = styles;

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
          newEnergy: cursorIndex == 7,
          completeText: completeText,
          onChange: _onPlateNumberChanged,
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
