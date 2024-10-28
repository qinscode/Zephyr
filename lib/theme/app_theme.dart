import 'package:flutter/material.dart';

class AppTheme {
  // 定义主题颜色
  static const Color backgroundColor = Color(0xFFF7F7F7);  // 浅灰色背景
  static const Color surfaceColor = Color(0xFFF7F7F7);    // 与背景相同的颜色
  static const Color searchBarColor = Color(0xFFEEEEEE);  // 添加搜索框背景色，更深的灰色
  static const Color primaryColor = Colors.orange;
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
        surface: surfaceColor,  // 使用 surface 替代 background
        onSurface: textColor,
        primary: primaryColor,
        onPrimary: surfaceColor,
        surfaceContainerHighest: searchBarColor,
      ),

      // AppBar 主题
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
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
        backgroundColor: surfaceColor,
        elevation: 0,
      ),

      // 弹窗主题
      dialogTheme: const DialogTheme(
        backgroundColor: Colors.white,
      ),

      // 卡片主题
      cardTheme: const CardTheme(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide.none,
        ),
      ),

      // 弹出菜单主题
      popupMenuTheme: const PopupMenuThemeData(
        color: Colors.white,
      ),

      // 底部Sheet主题
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
      ),

      // 导航栏主题
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {  // 使用 WidgetStateProperty
          if (states.contains(WidgetState.selected)) {  // 使用 WidgetState
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
        iconTheme: WidgetStateProperty.resolveWith((states) {  // 使用 WidgetStateProperty
          if (states.contains(WidgetState.selected)) {  // 使用 WidgetState
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

      // 搜索栏主题
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(searchBarColor),  // 使用 WidgetStateProperty
        elevation: WidgetStateProperty.all(0),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }
}
