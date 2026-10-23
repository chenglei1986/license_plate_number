import 'package:flutter/material.dart';
import 'package:license_plate_number/license_plate_number.dart';
import 'package:license_plate_number/src/keyboard_button.dart';

typedef PlateNumberChanged = void Function(int index, String value);

/// 中国车牌号输入键盘
class PlateKeyboard extends StatefulWidget {
  const PlateKeyboard({
    super.key,
    this.plateNumbers = const [],
    required this.keyboardController,
    this.styles = PlateStyles.light,
    this.newEnergy = false,
    this.completeText = '完成',
    this.enableHapticFeedback = false,
    this.onChange,
    this.onKeyPressed,
    this.animationController,
    this.onComplete,
  });

  final List<String> plateNumbers;
  final KeyboardController? keyboardController;
  final PlateStyles styles;

  /// 新能源车牌
  final bool newEnergy;

  /// 完成按钮文字
  final String completeText;

  /// 按下按键时是否触发触感反馈
  final bool enableHapticFeedback;
  final PlateNumberChanged? onChange;

  /// 任意按键（含退格，退格值为空字符串）被按下时的回调
  final ValueChanged<String>? onKeyPressed;
  final AnimationController? animationController;
  final VoidCallback? onComplete;

  @override
  State<PlateKeyboard> createState() => _PlateKeyboardState();
}

class _PlateKeyboardState extends State<PlateKeyboard> {
  Animation<Offset>? _offsetAnimation;

  @override
  void initState() {
    super.initState();
    final controller = widget.animationController;
    if (controller != null) {
      _offsetAnimation = Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.decelerate));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.keyboardController!;
    final slot = controller.pattern.slots[controller.cursorIndex];
    final page = controller.pattern.keyPages[slot.keyPage];
    final childAspectRatio =
        MediaQuery.of(context).orientation == Orientation.portrait
            ? page.aspectRatioPortrait
            : page.aspectRatioLandscape;
    final keyboard = SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            alignment: Alignment.centerRight,
            color: widget.styles.keyboardButtonColor,
            padding: const EdgeInsets.all(10),
            child: GestureDetector(
              child: Text(
                widget.completeText,
                style: TextStyle(
                  fontSize: 14,
                  color: widget.styles.completeButtonTextColor,
                  decoration: TextDecoration.none,
                ),
              ),
              onTap: () => widget.onComplete?.call(),
            ),
          ),
          Container(
            color: widget.styles.keyboardBackgroundColor,
            padding: const EdgeInsets.all(10),
            alignment: Alignment.bottomCenter,
            child: GridView.count(
              crossAxisCount: page.columns,
              childAspectRatio: childAspectRatio,
              shrinkWrap: true,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              physics: const NeverScrollableScrollPhysics(),
              children: _buildKeys(),
            ),
          ),
        ],
      ),
    );
    final offsetAnimation = _offsetAnimation;
    if (offsetAnimation != null) {
      return SlideTransition(position: offsetAnimation, child: keyboard);
    }
    return keyboard;
  }

  List<Widget> _buildKeys() {
    final controller = widget.keyboardController!;
    final slot = controller.pattern.slots[controller.cursorIndex];
    final page = controller.pattern.keyPages[slot.keyPage];
    final keys = <Widget>[
      for (final key in page.keys)
        _buildKeyboardButton(key, slot.chars.contains(key)),
      _buildBackspace(),
    ];
    return keys;
  }

  Widget _buildKeyboardButton(String data, bool enable) {
    return KeyboardButton(
      semanticsLabel: data,
      color: widget.styles.keyboardButtonColor,
      textColor: widget.styles.keyboardButtonTextColor,
      disabledColor: widget.styles.keyboardButtonDisabledColor,
      onPressed:
          enable
              ? () {
                int index = widget.keyboardController!.cursorIndex;
                if (index <= 7) {
                  widget.onChange?.call(index, data);
                  widget.onKeyPressed?.call(data);
                  widget.keyboardController!.cursorIndex++;
                  setState(() {});
                }
              }
              : null,
      enableHapticFeedback: widget.enableHapticFeedback,
      child: Text(data),
    );
  }

  Widget _buildBackspace() {
    return KeyboardButton(
      semanticsLabel: '退格',
      color: widget.styles.keyboardButtonColor,
      onPressed: () {
        int index = widget.keyboardController!.cursorIndex;
        widget.onChange?.call(index, '');
        widget.onKeyPressed?.call('');
        if (index > 0) {
          widget.keyboardController!.cursorIndex--;
        }
        setState(() {});
      },
      enableHapticFeedback: widget.enableHapticFeedback,
      child: Image(
        image: const AssetImage(
          'images/backspace.png',
          package: 'license_plate_number',
        ),
        width: 20,
        height: 20,
        color: widget.styles.keyboardButtonTextColor,
        colorBlendMode: BlendMode.srcIn,
      ),
    );
  }
}
