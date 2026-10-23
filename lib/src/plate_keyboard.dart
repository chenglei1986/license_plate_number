import 'package:flutter/material.dart';
import 'package:license_plate_number/license_plate_number.dart';
import 'package:license_plate_number/src/constants.dart';
import 'package:license_plate_number/src/keyboard_button.dart';

typedef PlateNumberChanged = void Function(int index, String value);

/// 中国车牌号输入键盘
class PlateKeyboard extends StatefulWidget {
  const PlateKeyboard({
    super.key,
    this.plateNumbers = const [],
    this.keyboardController,
    this.styles = PlateStyles.light,
    this.newEnergy = false,
    this.completeText = '完成',
    this.onChange,
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
  final PlateNumberChanged? onChange;
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
    int index = widget.keyboardController!.cursorIndex;
    double childAspectRatio;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      childAspectRatio = 0 == index ? 3 / 4 : 2 / 3;
    } else {
      childAspectRatio = 0 == index ? 2 / 1 : 16 / 9;
    }
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
              crossAxisCount: 0 == index ? 9 : 10,
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
    List<Widget> keys = [];
    int index = widget.keyboardController!.cursorIndex;
    if (0 == index) {
      /// 省份
      for (final element in provinces) {
        keys.add(_buildKeyboardButton(element, true));
      }
    } else {
      /// 数字
      for (final element in numbers) {
        keys.add(_buildKeyboardButton(element, index > 1));
      }

      /// 字母 Q ~ P
      for (final element in alphabets[0]) {
        keys.add(_buildKeyboardButton(element, true));
      }
      if (index > 5) {
        keys.add(_buildKeyboardButton(specials[0], true));
      }

      /// 领
      keys.add(_buildKeyboardButton(specials[1], index >= 6));

      /// 字母 A ~ L
      for (final element in alphabets[1]) {
        keys.add(_buildKeyboardButton(element, index > 0));
      }

      /// 警
      keys.add(_buildKeyboardButton(specials[2], index >= 6));

      /// 字母 Z ~ M
      for (final element in alphabets[2]) {
        keys.add(_buildKeyboardButton(element, index > 0));
      }

      /// 港
      keys.add(_buildKeyboardButton(specials[3], index >= 6));

      /// 澳
      keys.add(_buildKeyboardButton(specials[4], index >= 6));

      /// 挂
      keys.add(_buildKeyboardButton(specials[5], index >= 6));
    }

    /// 退格
    keys.add(_buildBackspace());
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
                  widget.keyboardController!.cursorIndex++;
                  setState(() {});
                }
              }
              : null,
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
        if (index > 0) {
          widget.keyboardController!.cursorIndex--;
        }
        setState(() {});
      },
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
