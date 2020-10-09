import 'dart:math';
import 'package:flutter/material.dart';
import 'package:license_plate_number/license_plate_number.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Brightness _brightness = Brightness.light;
  PlateStyles _plateStyles = PlateStyles.light;
  final KeyboardController _keyboardController = KeyboardController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'License plate number Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: _brightness,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('License plate number'),
          actions: [
            /// AppBar 弹出菜单
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(child: Text('dark'), value: 'dark'),
                PopupMenuItem(child: Text('light'), value: 'light'),
              ],
              onSelected: (action) {
                switch (action) {

                  /// 切换成黑暗主题
                  case 'dark':
                    _plateStyles = PlateStyles.dark;
                    _brightness = Brightness.dark;
                    break;

                  /// 切换成明亮主题
                  case 'light':
                    _plateStyles = PlateStyles.light;
                    _brightness = Brightness.light;
                    break;
                }
                setState(() {});
              },
            ),
          ],
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: MyHomePage(
            plateStyles: _plateStyles,
            keyboardController: _keyboardController,
          ),
          onTap: () {
            /// 点击键盘外区域收起键盘
            _keyboardController.hideKeyboard();
          },
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({
    this.plateStyles,
    this.keyboardController,
  });

  final PlateStyles plateStyles;
  final KeyboardController keyboardController;

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double screenWidth = mediaQuery.size.width;
    double screenHeight = mediaQuery.size.height;
    double inputFieldWidth = min(screenWidth, screenHeight) / 10;
    double inputFieldHeight = inputFieldWidth * 4 / 3;
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 30),

      /// 车牌号输入框
      child: PlateInputField(
        styles: plateStyles,
        inputFieldWidth: inputFieldWidth,
        inputFieldHeight: inputFieldHeight,
        keyboardController: keyboardController,
        plateSeparatorPadding: 8,
        plateSeparatorSize: 6,
        onChanged: (List<String> array, String value) {
          debugPrint(array.toString());
          debugPrint(value);
        },
      ),
    );
  }
}
