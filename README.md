# license_plate_number

```
[![pub package](https://img.shields.io/pub/v/license_plate_number.svg)](https://img.shields.io/pub/v/license_plate_number)
```

Flutter 车牌号输入组件，包含一个输入框和一个键盘。

- 支持自定义主题，自带黑暗和明亮两个默认主题
- 键盘支持横屏展示
- 内部处理了 Android 返回键的监听，点击返回键隐藏键盘
- 车牌号可选中单个号码进行修改

![](/Users/chenglei/git_project/license_plate_number/screenshots/screen_shot_portrait.png)

![](/Users/chenglei/git_project/license_plate_number/screenshots/screenshot_landscape_light.png)



## 使用说明

### 安装

```yaml
dependencies:
  license_plate_number: ^1.0.0
```

### 基本用法

Package 包含两个主要的组件，`PlateInputField`  和 `PlateKeyboard` 。

车牌号输入框`PlateInputField` 可以作为一个普通的 Widget 使用：

```dart
Container(
  child: PlateInputField(
    placeHolder: '沪A12345', // 初始值
    style: PlateStyle.light, // 主题
    inputFieldWidth: 40,     // 单个输入框宽度
    inputFieldHeight: 54,    // 单个输入框高度
    onChange: (List<String> array, String value) {
      // 监听输入内容
      // array ['沪', 'A', '1', '2', '3', '4', '5']
      // value 沪A12345
    },
  );
  alignment: Alignment.center,
)
```

`PlateKeyboard` 不直接使用，键盘的弹出与内容切换，由 `PlateInputField` 在内部控制，如果要在外部控制键盘的弹出与隐藏，可通过 `KeyboardController` 实现。

```dart
/// 定义 KeyboardController
KeyboardController _keyboardController = KeyboardController();

/// 弹出键盘
_keyboardController.showKeyboard(context);

/// 隐藏键盘
_keyboardController.hideKeyboard();

/// 判断键盘是否可见
_keyboardController.isKeyboardShowing()
```

```dart
PlateInputField(
  /// 设置 KeyboardController
  keyboardController: _keyboardController,
);
```



### 定制外观

组件内置了两款默认主题，同时支持自定义主题。

```dart
/// 方式一，使用构造函数
PlateStyles(
  /// 车牌号字体样式
  plateInputFieldTextStyle: TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 20,
    fontWeight: FontWeight.normal,
  ),
  /// 输入框背景
  plateInputFieldColor: Color(0xFF4A4A4A),
  /// 输入框边框
  plateInputBorder: Border.fromBorderSide(BorderSide(
    color: Color(0xFFFFFFFF),
    width: 2,
    style: BorderStyle.solid,
  )),
  /// 输入框获取焦点时的边框
  plateInputFocusedBorder: Border.fromBorderSide(BorderSide(
    color: Color(0xFF2196F3),
    width: 2,
    style: BorderStyle.solid,
  )),
  /// 输入框边框圆角半径
  plateInputBorderRadius: const BorderRadius.all(Radius.circular(8.0)),
  /// 省市与号码之间分隔符的颜色
  plateSeparatorColor: Color(0xFFFFFFFF),
  
  /// 键盘背景色
  keyboardBackgroundColor: Color(0xFF131313),
  /// 键盘按钮字体颜色
  keyboardButtonTextColor: Color(0xFFFFFFFF),
  /// 键盘按钮背景色
  keyboardButtonColor: Color(0xFF4A4A4A),
  /// 键盘按钮不可用时的背景色
  keyboardButtonDisabledColor: Color(0x994A4A4A),
);
```

```dart
/// 方式二，使用默认主题替换
PlateStyles.dark.copyWith(
  keyboardBackgroundColorDark: Color(0xFF000000),
);
```

