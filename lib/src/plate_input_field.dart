import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/widgets.dart';
import 'package:license_plate_number/license_plate_number.dart';
import 'package:license_plate_number/src/plate_keyboard.dart';

class PlateInputField extends StatefulWidget {
  const PlateInputField({
    this.placeHolder = '',
    this.styles = PlateStyles.dark,
    this.inputFieldWidth = 40,
    this.inputFieldHeight = 54,
    this.plateSeparatorSize = 6,
    this.plateSeparatorPadding = 8,
    this.keyboardController,
    this.onChanged,
  }) : assert(placeHolder.length <= 8,
            'plateNumber\'s length should be less than 8.');

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

  /// 输入变化监听器
  ///
  /// * [array] - 车牌号字符数组
  /// * [value] - 车牌号字符串
  final void Function(List<String> array, String value)? onChanged;

  @override
  _PlateInputFieldState createState() => _PlateInputFieldState();
}

class _PlateInputFieldState extends State<PlateInputField>
    with SingleTickerProviderStateMixin {
  /// 键盘进入和退出动画控制器
  AnimationController? _controller;

  /// 键盘控制器
  KeyboardController? _keyboardController;
  late ValueNotifier<String> _valueNotifier;

  @override
  void initState() {
    super.initState();
    String plateNumber = widget.placeHolder;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _valueNotifier = ValueNotifier(plateNumber);
    _keyboardController = widget.keyboardController;
    if (null == _keyboardController) {
      _keyboardController = KeyboardController();
    }
    _keyboardController!._valueNotifier = _valueNotifier;
    _keyboardController!.plateNumber = plateNumber;
    _keyboardController!.onPlateNumberChanged = onPlateNumberChanged;
    _keyboardController!.animationController = _controller;
  }

  @override
  void dispose() {
    super.dispose();
    _valueNotifier.dispose();
    _keyboardController!.dispose();
  }

  void onPlateNumberChanged(int index, String value) {
    _keyboardController!._plateNumbers[index] = value;
    _keyboardController!._plateNumber =
        _keyboardController!._plateNumbers.join();
    if (value.isNotEmpty) {
      _keyboardController!._valueNotifier.value =
          _keyboardController!._plateNumber;
      if (index >= 7 && _keyboardController!.cursorIndex >= 7) {
        _keyboardController!.hideKeyboard();
      }
    } else if (value.isEmpty) {
      setState(() {});
    }
    if (widget.onChanged != null) {
      widget.onChanged!(_keyboardController!._plateNumbers,
          _keyboardController!._plateNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    _keyboardController!.styles = widget.styles;
    return WillPopScope(
      child: ValueListenableBuilder(
        valueListenable: _valueNotifier,
        builder: (context, String value, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildInputFields(),
          );
        },
      ),
      onWillPop: () {
        if (_keyboardController!.isKeyboardShowing()) {
          _keyboardController!.hideKeyboard();
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
    );
  }

  List<Widget> _buildInputFields() {
    List<Widget> children = [];
    for (int i = 0; i < _keyboardController!._plateNumbers.length; i++) {
      children.add(_buildSingleField(_keyboardController!._plateNumbers[i], i));
      if (1 == i) {
        children.add(_buildSeparator());
      }
    }
    return children;
  }

  Widget _buildSingleField(String data, int index) {
    bool focused = _keyboardController!.cursorIndex == index;
    bool newEnergy = index == 7;
    Border commonBorder = focused
        ? widget.styles.plateInputFocusedBorder
        : widget.styles.plateInputBorder;
    Border border = newEnergy && !focused ? Border() : commonBorder;
    var text = Text(
      data.isEmpty && newEnergy ? '新能源' : data,
      style: newEnergy && data.isEmpty
          ? widget.styles.newEnergyPlaceHolderTextStyle
          : widget.styles.plateInputFieldTextStyle,
    );
    var container = Container(
      width: newEnergy && !focused
          ? widget.inputFieldWidth - 4
          : widget.inputFieldWidth,
      height: newEnergy && !focused
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
      child: container,
      color: Color(0xFF666666),
      borderType: BorderType.RRect,
      radius: widget.styles.plateInputBorderRadius,
      padding: const EdgeInsets.all(1),
      strokeWidth: 2,
      dashPattern: [4, 2],
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: newEnergy && !focused ? 3 : 2),
      child: GestureDetector(
        child: newEnergy && !focused ? newEnergyField : container,
        onTap: () {
          _keyboardController!.cursorIndex = index;
          _keyboardController!.showKeyboard(context);
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
        shape: CircleBorder(),
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

  /// 当前光标位置
  int cursorIndex = 0;

  /// 键盘悬浮窗口
  OverlayEntry? _keyboardOverlay;

  /// 键盘进入和退出动画控制器
  AnimationController? _controller;

  /// 键盘可见状态
  bool _isKeyboardShowing = false;

  /// 主题
  PlateStyles _styles = PlateStyles.light;
  late ValueNotifier<String> _valueNotifier;
  Function(int index, String value)? _onPlateNumberChanged;

  set plateNumber(String plateNumber) {
    _plateNumber = plateNumber;
    List<String> numbers = plateNumber.split('');
    _plateNumbers.fillRange(0, _plateNumbers.length, '');
    _plateNumbers.replaceRange(0, numbers.length, numbers);
    cursorIndex = numbers.length;
    _valueNotifier.value = plateNumber;
  }

  String get plateNumber => _plateNumber;

  set animationController(AnimationController? controller) =>
      _controller = controller;

  set styles(PlateStyles styles) => _styles = styles;

  set onPlateNumberChanged(onPlateNumberChanged(int index, String value)) =>
      _onPlateNumberChanged = onPlateNumberChanged;

  /// 显示键盘
  void showKeyboard(BuildContext context) {
    if (_keyboardOverlay != null) {
      _keyboardOverlay!.remove();
    }
    _keyboardOverlay = OverlayEntry(
      builder: (context) {
        return PlateKeyboard(
          plateNumbers: _plateNumbers,
          keyboardController: this,
          styles: _styles,
          newEnergy: cursorIndex == 7,
          onChange: _onPlateNumberChanged,
          animationController: _controller,
          onComplete: () => hideKeyboard(),
        );
      },
    );
    Overlay.of(context)!.insert(_keyboardOverlay!);
    if (!_isKeyboardShowing) {
      _controller!.forward();
      _isKeyboardShowing = true;
    }
  }

  /// 隐藏键盘
  void hideKeyboard() {
    if (isKeyboardShowing()) {
      _controller!.reverse();
    }
    _isKeyboardShowing = false;
  }

  /// 键盘是否可见
  bool isKeyboardShowing() {
    return _keyboardOverlay != null && _isKeyboardShowing;
  }

  /// 移除悬浮窗口
  void dispose() {
    if (_keyboardOverlay != null) {
      _keyboardOverlay!.remove();
      _keyboardOverlay = null;
    }
  }
}
