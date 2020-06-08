import 'package:flutter/widgets.dart';

/// 车牌输入框和键盘样式
class PlateStyles {
  const PlateStyles({
    this.plateInputFieldTextStyle = plateInputFieldTextStyleLight,
    this.newEnergyPlaceHolderTextStyle = newEnergyPlaceHolderTextStyleDark,
    this.plateInputFieldColor = plateInputFieldColorLight,
    this.plateInputBorder = plateInputBorderLight,
    this.plateInputFocusedBorder = plateInputFocusedBorderLight,
    this.plateInputBorderRadius = const Radius.circular(8.0),
    this.plateSeparatorColor = plateSeparatorColorLight,
    this.keyboardBackgroundColor = keyboardBackgroundColorLight,
    this.keyboardButtonTextColor = keyboardButtonTextColorLight,
    this.keyboardButtonColor = keyboardButtonColorLight,
    this.keyboardButtonDisabledColor = keyboardButtonDisabledColorLight,
  });

  /// 车牌号字体样式
  final TextStyle plateInputFieldTextStyle;

  /// 新能源输入框占位字符样式
  final TextStyle newEnergyPlaceHolderTextStyle;

  /// 输入框背景
  final Color plateInputFieldColor;

  /// 输入框边框
  final Border plateInputBorder;

  /// 输入框获取焦点时的边框
  final Border plateInputFocusedBorder;

  /// 输入框边框圆角半径
  final Radius plateInputBorderRadius;

  /// 省市与号码之间分隔符的颜色
  final Color plateSeparatorColor;

  /// 键盘背景色
  final Color keyboardBackgroundColor;

  /// 键盘按钮字体颜色
  final Color keyboardButtonTextColor;

  /// 键盘按钮背景色
  final Color keyboardButtonColor;

  /// 键盘按钮不可用时的背景色
  final Color keyboardButtonDisabledColor;

  /// 黑暗风格车牌号字体样式
  static const TextStyle plateInputFieldTextStyleDark = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 20,
    fontWeight: FontWeight.normal,
  );

  /// 黑暗风格车牌号字体样式
  static const TextStyle newEnergyPlaceHolderTextStyleDark = TextStyle(
    color: Color(0xFFDDDDDD),
    fontSize: 10,
    fontWeight: FontWeight.normal,
  );

  /// 黑暗风格输入框背景色
  static const Color plateInputFieldColorDark = Color(0xFF4A4A4A);

  /// 黑暗风格输入框边框
  static const Border plateInputBorderDark = Border.fromBorderSide(BorderSide(
    color: Color(0xFFFFFFFF),
    width: 2,
    style: BorderStyle.solid,
  ));

  /// 黑暗风格输入框获取焦点时的边框
  static const Border plateInputFocusedBorderDark =
      Border.fromBorderSide(BorderSide(
    color: Color(0xFF2196F3),
    width: 2,
    style: BorderStyle.solid,
  ));

  /// 黑暗风格分隔符的颜色
  static const Color plateSeparatorColorDark = Color(0xFFFFFFFF);

  /// 黑暗风格键盘背景色
  static const Color keyboardBackgroundColorDark = Color(0xFF131313);

  /// 黑暗风格键盘按钮字体颜色
  static const Color keyboardButtonTextColorDark = Color(0xFFFFFFFF);

  /// 黑暗风格键盘按钮背景色
  static const Color keyboardButtonColorDark = Color(0xFF4A4A4A);

  /// 黑暗风格键盘按钮不可用时的背景色
  static const Color keyboardButtonDisabledColorDark = Color(0x994A4A4A);

  /// 明亮风格车牌号字体样式
  static const TextStyle plateInputFieldTextStyleLight = TextStyle(
    color: Color(0xFF333333),
    fontSize: 20,
    fontWeight: FontWeight.normal,
  );

  /// 明亮风格车牌号字体样式
  static const TextStyle newEnergyPlaceHolderTextStyleLight = TextStyle(
    color: Color(0xFF666666),
    fontSize: 10,
    fontWeight: FontWeight.normal,
  );

  /// 明亮风格输入框背景色
  static const Color plateInputFieldColorLight = Color(0xFFFFFFFF);

  /// 明亮风格输入框边框
  static const Border plateInputBorderLight = Border.fromBorderSide(BorderSide(
    color: Color(0xFF333333),
    width: 2,
    style: BorderStyle.solid,
  ));

  /// 明亮风格输入框获取焦点时的边框
  static const Border plateInputFocusedBorderLight =
      Border.fromBorderSide(BorderSide(
    color: Color(0xFF2196F3),
    width: 2,
    style: BorderStyle.solid,
  ));

  /// 明亮风格分隔符的颜色
  static const Color plateSeparatorColorLight = Color(0xFF333333);

  /// 明亮风格键盘背景色
  static const Color keyboardBackgroundColorLight = Color(0xFFE1E1E1);

  /// 明亮风格键盘按钮字体颜色
  static const Color keyboardButtonTextColorLight = Color(0xFF333333);

  /// 明亮风格键盘按钮背景色
  static const Color keyboardButtonColorLight = Color(0xFFFFFFFF);

  /// 明亮风格键盘按钮不可用时的背景色
  static const Color keyboardButtonDisabledColorLight = Color(0x99FFFFFF);

  /// 黑暗风格
  static const PlateStyles dark = const PlateStyles(
    plateInputFieldTextStyle: plateInputFieldTextStyleDark,
    newEnergyPlaceHolderTextStyle: newEnergyPlaceHolderTextStyleDark,
    plateInputFieldColor: plateInputFieldColorDark,
    plateInputBorder: plateInputBorderDark,
    plateInputFocusedBorder: plateInputFocusedBorderDark,
    plateInputBorderRadius: const Radius.circular(8.0),
    plateSeparatorColor: plateSeparatorColorDark,
    keyboardBackgroundColor: keyboardBackgroundColorDark,
    keyboardButtonTextColor: keyboardButtonTextColorDark,
    keyboardButtonColor: keyboardButtonColorDark,
    keyboardButtonDisabledColor: keyboardButtonDisabledColorDark,
  );

  /// 明亮风格
  static const PlateStyles light = const PlateStyles(
    plateInputFieldTextStyle: plateInputFieldTextStyleLight,
    newEnergyPlaceHolderTextStyle: newEnergyPlaceHolderTextStyleLight,
    plateInputFieldColor: plateInputFieldColorLight,
    plateInputBorder: plateInputBorderLight,
    plateInputFocusedBorder: plateInputFocusedBorderLight,
    plateInputBorderRadius: const Radius.circular(8.0),
    plateSeparatorColor: plateSeparatorColorLight,
    keyboardBackgroundColor: keyboardBackgroundColorLight,
    keyboardButtonTextColor: keyboardButtonTextColorLight,
    keyboardButtonColor: keyboardButtonColorLight,
    keyboardButtonDisabledColor: keyboardButtonDisabledColorLight,
  );

  PlateStyles copyWith({
    TextStyle plateInputFieldTextStyle,
    TextStyle newEnergyPlaceHolderTextStyle,
    Color plateInputFieldColor,
    Border plateInputBorder,
    Border plateInputFocusedBorder,
    BorderRadius plateInputBorderRadius,
    Color plateSeparatorColor,
    Color keyboardBackgroundColor,
    Color keyboardButtonTextColor,
    Color keyboardButtonColor,
    Color keyboardButtonDisabledColor,
  }) {
    return PlateStyles(
      plateInputFieldTextStyle:
          plateInputFieldTextStyle ?? this.plateInputFieldTextStyle,
      newEnergyPlaceHolderTextStyle:
          newEnergyPlaceHolderTextStyle ?? this.newEnergyPlaceHolderTextStyle,
      plateInputFieldColor: plateInputFieldColor ?? this.plateInputFieldColor,
      plateInputBorder: plateInputBorder ?? this.plateInputBorder,
      plateInputFocusedBorder:
          plateInputFocusedBorder ?? this.plateInputFocusedBorder,
      plateInputBorderRadius:
          plateInputBorderRadius ?? this.plateInputBorderRadius,
      plateSeparatorColor: plateSeparatorColor ?? this.plateSeparatorColor,
      keyboardBackgroundColor:
          keyboardBackgroundColor ?? this.keyboardBackgroundColor,
      keyboardButtonTextColor:
          keyboardButtonTextColor ?? this.keyboardButtonTextColor,
      keyboardButtonColor: keyboardButtonColor ?? this.keyboardButtonColor,
      keyboardButtonDisabledColor:
          keyboardButtonDisabledColor ?? this.keyboardButtonDisabledColor,
    );
  }
}
