import 'package:license_plate_number/src/constants.dart';

/// 车牌槽位：描述某一位允许的字符集与展示信息
class PlateSlot {
  const PlateSlot(this.chars, {this.placeholder, this.keyPage = 0});

  /// 该槽位允许的字符集（单个字符）
  final Set<String> chars;

  /// 占位提示文字。非空时该槽位以虚线框展示，如新能源最后一位。
  final String? placeholder;

  /// 该槽位使用的键盘页索引
  final int keyPage;
}

/// 键盘页：一组按键的网格布局
class KeyPage {
  const KeyPage({
    required this.columns,
    required this.keys,
    required this.aspectRatioPortrait,
    required this.aspectRatioLandscape,
  });

  /// 网格列数
  final int columns;

  /// 按键内容（按展示顺序排列），退格键由键盘自动追加
  final List<String> keys;

  /// 竖屏按键纵横比
  final double aspectRatioPortrait;

  /// 横屏按键纵横比
  final double aspectRatioLandscape;
}

/// 车牌模式：描述某一国家或地区的车牌槽位序列、键盘布局与分隔规则
class PlatePattern {
  const PlatePattern({
    required this.code,
    required this.name,
    required this.slots,
    required this.keyPages,
    this.slotSeparators = const [],
  });

  /// 模式代码，如 CN、US、JP
  final String code;

  /// 模式名称
  final String name;

  /// 槽位序列
  final List<PlateSlot> slots;

  /// 键盘页
  final List<KeyPage> keyPages;

  /// 在该槽位之后展示分隔符（如省份与序号之间）
  final List<int> slotSeparators;

  /// 槽位数
  int get length => slots.length;
}

/// 内置车牌模式
abstract final class PlatePatterns {
  /// 中国车牌：普通 7 位与新能源 8 位。
  ///
  /// - 第 1 位：省份简称或军车字头（省份键盘页）
  /// - 第 2 位：发牌机关字母
  /// - 第 3 ~ 6 位：字母 + 数字
  /// - 第 7 位：字母 + 数字 + 特殊后缀（学/领/警/港/澳/挂/临）
  /// - 第 8 位（新能源）：仅字母 D/F 和数字（GA36 小型新能源规则）
  static const PlatePattern china = PlatePattern(
    code: 'CN',
    name: '中国车牌',
    slots: [
      PlateSlot({...provinces, ...militaryCodes}),
      PlateSlot({...letters}, keyPage: 1),
      PlateSlot({...numbers, ...letters}, keyPage: 1),
      PlateSlot({...numbers, ...letters}, keyPage: 1),
      PlateSlot({...numbers, ...letters}, keyPage: 1),
      PlateSlot({...numbers, ...letters}, keyPage: 1),
      PlateSlot({...numbers, ...letters, ...specials}, keyPage: 1),
      PlateSlot({...numbers, 'D', 'F'}, placeholder: '新能源', keyPage: 1),
    ],
    keyPages: [
      KeyPage(
        columns: 9,
        keys: [...provinces, ...militaryCodes],
        aspectRatioPortrait: 3 / 4,
        aspectRatioLandscape: 2 / 1,
      ),
      KeyPage(
        columns: 10,
        keys: alnumKeys,
        aspectRatioPortrait: 2 / 3,
        aspectRatioLandscape: 16 / 9,
      ),
    ],
    slotSeparators: [1],
  );

  /// 韩国车牌（2006 式）：3 位数字 + 谚文字母 + 4 位数字，如 123가4567。
  ///
  /// 谚文字母集为乘用车常用 24 个；商用车等类型用字不同，可按需扩展。
  static const PlatePattern korea = PlatePattern(
    code: 'KR',
    name: '韩国车牌',
    slots: [
      PlateSlot({...numbers}, keyPage: 0),
      PlateSlot({...numbers}, keyPage: 0),
      PlateSlot({...numbers}, keyPage: 0),
      PlateSlot({...koreanLetters}, keyPage: 1),
      PlateSlot({...numbers}, keyPage: 0),
      PlateSlot({...numbers}, keyPage: 0),
      PlateSlot({...numbers}, keyPage: 0),
      PlateSlot({...numbers}, keyPage: 0),
    ],
    keyPages: [
      KeyPage(
        columns: 5,
        keys: numbers,
        aspectRatioPortrait: 3 / 2,
        aspectRatioLandscape: 3 / 1,
      ),
      KeyPage(
        columns: 8,
        keys: koreanLetters,
        aspectRatioPortrait: 3 / 4,
        aspectRatioLandscape: 2 / 1,
      ),
    ],
  );

  /// 美国车牌通用宽松模式：3 + 4 位字母数字组合，如 ABC 1234。
  ///
  /// 各州规则差异很大（尺寸组合、禁用字母、vanity 自定义），
  /// 此处为不限字母位置的通用模式，仅排除易混淆的 I 和 O。
  static const PlatePattern unitedStates = PlatePattern(
    code: 'US',
    name: '美国车牌（通用）',
    slots: [
      PlateSlot({...numbers, ...letters}, keyPage: 0),
      PlateSlot({...numbers, ...letters}, keyPage: 0),
      PlateSlot({...numbers, ...letters}, keyPage: 0),
      PlateSlot({...numbers, ...letters}, keyPage: 0),
      PlateSlot({...numbers, ...letters}, keyPage: 0),
      PlateSlot({...numbers, ...letters}, keyPage: 0),
      PlateSlot({...numbers, ...letters}, keyPage: 0),
    ],
    keyPages: [
      KeyPage(
        columns: 10,
        keys: [...numbers, ...letters],
        aspectRatioPortrait: 2 / 3,
        aspectRatioLandscape: 16 / 9,
      ),
    ],
    slotSeparators: [2],
  );
}
