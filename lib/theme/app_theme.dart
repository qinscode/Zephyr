import 'package:flutter/material.dart';

class AppTheme {
  // 定义主题颜色
  static const Color backgroundColor = Color(0xFFFFFBE6);  // 浅黄色背景
  static const Color surfaceColor = Color(0xFFFFFBE6);    // 修改为与背景相同的颜色
  static const Color primaryColor = Colors.blue;
  static const Color textColor = Colors.black;
  static const Color secondaryTextColor = Colors.grey;

  // 定义主题数据
  static ThemeData get lightTheme {
    return ThemeData(
      // 基础背景色设置
      scaffoldBackgroundColor: backgroundColor,
      canvasColor: backgroundColor,
      dialogBackgroundColor: backgroundColor,
      cardColor: Colors.white,  // 卡片保持白色背景

      // 颜色方案
      colorScheme: const ColorScheme.light(
        background: backgroundColor,
        surface: surfaceColor,
        onSurface: textColor,
        primary: primaryColor,
        onPrimary: surfaceColor,
      ),

      // AppBar 主题
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,  // 使用统一的背景色
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,  // 使用统一的背景色
        elevation: 0,
      ),

      // 弹窗主题
      dialogTheme: const DialogTheme(
        backgroundColor: Colors.white,  // 弹窗保持白色背景
      ),

      // 卡片主题
      cardTheme: const CardTheme(
        color: Colors.white,  // 卡片保持白色背景
        elevation: 1,
      ),

      // 弹出菜单主题
      popupMenuTheme: const PopupMenuThemeData(
        color: Colors.white,  // 弹出菜单保持白色背景
      ),

      // 底部Sheet主题
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,  // 底部Sheet保持白色背景
      ),

      // 导航栏主题
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,  // 使用统一的背景色
        elevation: 0,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              color: primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            );
          }
          return const TextStyle(
            color: secondaryTextColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          );
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 65,
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(
              size: 25,
              color: primaryColor,
            );
          }
          return const IconThemeData(
            size: 25,
            color: secondaryTextColor,
          );
        }),
      ),
    );
  }
}
