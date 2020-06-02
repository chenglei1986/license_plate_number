import 'package:flutter/widgets.dart';
import 'package:license_plate_number/license_plate_number.dart';

/// 车牌号输入键盘按键
class KeyboardButton extends StatefulWidget {
  const KeyboardButton({
    Key key,
    @required this.child,
    this.textColor = PlateStyles.keyboardButtonTextColorDark,
    this.textSize = 14,
    this.color = PlateStyles.keyboardButtonColorDark,
    this.pressedOpacity = 0.8,
    this.disabledColor = PlateStyles.keyboardButtonDisabledColorDark,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    @required this.onPressed,
  })  : assert(pressedOpacity == null ||
            (pressedOpacity >= 0.0 && pressedOpacity <= 1.0)),
        super(key: key);

  /// 内容
  final Widget child;

  /// 按键字体颜色
  final Color textColor;

  /// 按键字体大小
  final double textSize;

  /// 背景色
  final Color color;

  /// 按键被按下时的透明度
  final double pressedOpacity;

  /// 按键不可用时的背景色
  final Color disabledColor;

  /// 边框圆角半径
  final BorderRadius borderRadius;

  /// 按键被按下时的事件响应回调函数
  final VoidCallback onPressed;

  /// 按键是否可用
  bool get enabled => onPressed != null;

  @override
  _KeyboardButtonState createState() => _KeyboardButtonState();
}

class _KeyboardButtonState extends State<KeyboardButton> {
  bool _buttonPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.enabled;
    final Color backgroundColor = enabled ? widget.color : widget.disabledColor;
    final Color textColor =
        enabled ? widget.textColor : widget.textColor.withAlpha(0x99);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? _handleTapDown : null,
      onTapUp: enabled ? _handleTapUp : null,
      onTapCancel: enabled ? _handleTapCancel : null,
      onTap: widget.onPressed,
      child: Opacity(
        opacity: _buttonPressed ? widget.pressedOpacity : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: widget.borderRadius,
          ),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: DefaultTextStyle(
              style: TextStyle(
                color: textColor,
                fontSize: widget.textSize,
                fontWeight: FontWeight.normal,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }

  void _handleTapDown(TapDownDetails event) {
    _buttonPressed = true;
    setState(() {});
  }

  void _handleTapUp(TapUpDetails event) {
    _buttonPressed = false;
    setState(() {});
  }

  void _handleTapCancel() {
    _buttonPressed = false;
    setState(() {});
  }
}
