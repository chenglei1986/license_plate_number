import 'package:flutter/widgets.dart';

/// 车牌号单个字符输入框
class SinglePlateNumberField {
  const SinglePlateNumberField(
    this.text, {
    this.textStyle,
    this.decoration,
  }) : assert(text.length < 2,
            'SinglePlateNumberField can only accept single character as its content');

  /// 车牌号单个字符
  final String text;

  /// 字体样式
  final TextStyle? textStyle;

  /// 边框及背景
  final Decoration? decoration;
}
