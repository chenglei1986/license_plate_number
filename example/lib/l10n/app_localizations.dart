import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// 示例应用的轻量多语言支持（手写 delegate，无需 codegen）。
///
/// 支持中文、英语、韩语、日语四种界面语言，可在应用内手动切换。
class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const List<Locale> supportedLocales = [
    Locale('zh'),
    Locale('en'),
    Locale('ko'),
    Locale('ja'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// 各语言的本地化名称（语言菜单展示用）
  static String localeName(Locale locale) => switch (locale.languageCode) {
    'zh' => '中文',
    'ko' => '한국어',
    'ja' => '日本語',
    _ => 'English',
  };

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _values = <String, Map<String, String>>{
    'zh': {
      'appTitle': '车牌输入',
      'themeTooltip': '切换主题',
      'languageTooltip': '语言',
      'systemDefault': '跟随系统',
      'patternSection': '车牌制式',
      'slots': '{n} 位',
      'pattern_CN': '中国',
      'pattern_KR': '韩国',
      'pattern_US': '美国',
      'pattern_JP': '日本',
      'hapticTitle': '触感反馈',
      'hapticSubtitle': '按下按键时振动',
      'dismissTitle': '点击空白收起键盘',
      'dismissSubtitle': '点击输入框空白区域时',
      'complete': '完成',
      'newEnergy': '新能源',
      'semanticsField': '车牌号',
    },
    'en': {
      'appTitle': 'License Plate',
      'themeTooltip': 'Toggle theme',
      'languageTooltip': 'Language',
      'systemDefault': 'System default',
      'patternSection': 'Plate format',
      'slots': '{n} chars',
      'pattern_CN': 'China',
      'pattern_KR': 'Korea',
      'pattern_US': 'US',
      'pattern_JP': 'Japan',
      'hapticTitle': 'Haptic feedback',
      'hapticSubtitle': 'Vibrate on key press',
      'dismissTitle': 'Tap blank area to close',
      'dismissSubtitle': 'When tapping outside the input fields',
      'complete': 'Done',
      'newEnergy': 'New Energy',
      'semanticsField': 'License plate',
    },
    'ko': {
      'appTitle': '번호판 입력',
      'themeTooltip': '테마 전환',
      'languageTooltip': '언어',
      'systemDefault': '시스템 기본값',
      'patternSection': '번호판 형식',
      'slots': '{n}자리',
      'pattern_CN': '중국',
      'pattern_KR': '한국',
      'pattern_US': '미국',
      'pattern_JP': '일본',
      'hapticTitle': '햅틱 피드백',
      'hapticSubtitle': '키를 누를 때 진동',
      'dismissTitle': '빈 곳 탭하여 키보드 닫기',
      'dismissSubtitle': '입력란 외부를 탭할 때',
      'complete': '완료',
      'newEnergy': '신에너지',
      'semanticsField': '번호판',
    },
    'ja': {
      'appTitle': 'ナンバープレート',
      'themeTooltip': 'テーマ切替',
      'languageTooltip': '言語',
      'systemDefault': 'システム既定',
      'patternSection': 'ナンバータイプ',
      'slots': '{n}桁',
      'pattern_CN': '中国',
      'pattern_KR': '韓国',
      'pattern_US': '米国',
      'pattern_JP': '日本',
      'hapticTitle': '触感フィードバック',
      'hapticSubtitle': 'キー押下で振動',
      'dismissTitle': '空白タップでキーボードを閉じる',
      'dismissSubtitle': '入力欄の外側をタップしたとき',
      'complete': '完了',
      'newEnergy': '新エネルギー',
      'semanticsField': 'ナンバープレート',
    },
  };

  String _t(String key) =>
      _values[locale.languageCode]?[key] ?? _values['en']![key]!;

  String get appTitle => _t('appTitle');

  String get themeTooltip => _t('themeTooltip');

  String get languageTooltip => _t('languageTooltip');

  String get systemDefault => _t('systemDefault');

  String get patternSection => _t('patternSection');

  String slots(int count) => _t('slots').replaceAll('{n}', '$count');

  String patternName(String code) => _t('pattern_$code');

  String get hapticTitle => _t('hapticTitle');

  String get hapticSubtitle => _t('hapticSubtitle');

  String get dismissTitle => _t('dismissTitle');

  String get dismissSubtitle => _t('dismissSubtitle');

  /// 键盘完成按钮文字，传给 PlateInputField.completeText
  String get complete => _t('complete');

  /// 新能源占位文字，传给 PlateInputField.newEnergyPlaceHolder
  String get newEnergy => _t('newEnergy');

  /// 输入框语义标签，传给 PlateInputField.semanticsLabel
  String get semanticsField => _t('semanticsField');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (supported) => supported.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// MaterialApp 需要的全局本地化 delegates
const globalDelegates = <LocalizationsDelegate<dynamic>>[
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];
