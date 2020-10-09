import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:license_plate_number/license_plate_number.dart';
import 'package:license_plate_number/src/constants.dart';
import 'package:license_plate_number/src/keyboard_button.dart';

typedef PlateNumberChanged = void Function(int index, String value);

/// 中国车牌号输入键盘
class PlateKeyboard extends StatefulWidget {
  PlateKeyboard({
    this.plateNumbers,
    this.currentIndex,
    this.styles,
    this.newEnergy,
    this.onChange,
    this.animationController,
    this.onComplete,
  });

  final List<String> plateNumbers;
  final int currentIndex;
  final PlateStyles styles;
  final bool newEnergy;
  final PlateNumberChanged onChange;
  final AnimationController animationController;
  final VoidCallback onComplete;

  @override
  _PlateKeyboardState createState() => _PlateKeyboardState();
}

class _PlateKeyboardState extends State<PlateKeyboard> {
  int _index;
  Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _index = widget.currentIndex;
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.decelerate,
    ));
  }

  @override
  Widget build(BuildContext context) {
    double childAspectRatio;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      childAspectRatio = 0 == _index ? 3 / 4 : 2 / 3;
    } else {
      childAspectRatio = 0 == _index ? 2 / 1 : 16 / 9;
    }
    return SlideTransition(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                child: Text(
                  '完成',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2196F3),
                    decoration: TextDecoration.none,
                  ),
                ),
                onTap: () => widget.onComplete?.call(),
              ),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    width: 1,
                    color: widget.styles.keyboardBackgroundColor,
                  ),
                ),
              ),
            ),
            Container(
              color: widget.styles.keyboardBackgroundColor,
              padding: EdgeInsets.all(10),
              alignment: Alignment.bottomCenter,
              child: GridView.count(
                crossAxisCount: 0 == _index ? 9 : 10,
                childAspectRatio: childAspectRatio,
                shrinkWrap: true,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                children: _buildKeys(),
                physics: NeverScrollableScrollPhysics(),
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ),
      ),
      position: _offsetAnimation,
    );
  }

  List<Widget> _buildKeys() {
    List<Widget> keys = [];
    if (0 == _index) {
      /// 省份
      provinces.forEach(
          (element) => keys.add(_buildKeyboardButton(element, 0 == _index)));
    } else {
      /// 数字
      numbers.forEach(
          (element) => keys.add(_buildKeyboardButton(element, _index > 1)));

      /// 字母 Q ~ P
      alphabets[0].forEach((element) {
        if (element != 'O') {
          keys.add(_buildKeyboardButton(element, true));
        } else if ('O' == element) {
          if (_index < 5) {
            keys.add(_buildKeyboardButton(element, true));
          } else if (5 == _index) {
            keys.add(_buildKeyboardButton(element, false));
          }
        }
      });
      if (_index > 5) {
        keys.add(_buildKeyboardButton(specials[0], true));
      }

      /// 领
      keys.add(_buildKeyboardButton(specials[1], _index >= 6));

      /// 字母 A ~ L
      alphabets[1].forEach(
          (element) => keys.add(_buildKeyboardButton(element, _index > 0)));

      /// 警
      keys.add(_buildKeyboardButton(specials[2], _index >= 6));

      /// 字母 Z ~ M
      alphabets[2].forEach(
          (element) => keys.add(_buildKeyboardButton(element, _index > 0)));

      /// 港
      keys.add(_buildKeyboardButton(specials[3], _index >= 6));

      /// 澳
      keys.add(_buildKeyboardButton(specials[4], _index >= 6));
    }

    /// 退格
    keys.add(_buildBackspace());
    return keys;
  }

  Widget _buildKeyboardButton(String data, bool enable) {
    return KeyboardButton(
      child: Text(data),
      color: widget.styles.keyboardButtonColor,
      textColor: widget.styles.keyboardButtonTextColor,
      disabledColor: widget.styles.keyboardButtonDisabledColor,
      onPressed: enable
          ? () {
              if (_index <= 7) {
                widget.onChange(_index, data);
                _index++;
                setState(() {});
              }
            }
          : null,
    );
  }

  Widget _buildBackspace() {
    return KeyboardButton(
      child: Image(
        image:
            AssetImage('images/backspace.png', package: 'license_plate_number'),
        width: 20,
        height: 20,
        color: widget.styles.keyboardButtonTextColor,
        colorBlendMode: BlendMode.srcIn,
      ),
      color: widget.styles.keyboardButtonColor,
      onPressed: () {
        widget.onChange(_index, '');
        if (_index > 0) {
          _index--;
        }
        setState(() {});
      },
    );
  }
}
