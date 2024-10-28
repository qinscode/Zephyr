// 背景类型枚举

import 'package:flutter/material.dart';

enum BackgroundType {
  none,      // 无背景
  preset,    // 预设背景
}

// 背景类
class NoteBackground {
  final BackgroundType type;
  final String? assetPath;  // 预设背景的资源路径
  final double? opacity;    // 背景透明度
  final bool isTileable;    // 是否可平铺
  final Color textColor;    // 添加字体颜色属性

  const NoteBackground({
    required this.type,
    this.assetPath,
    this.opacity = 1.0,
    this.isTileable = false,
    this.textColor = Colors.black,  // 默认黑色
  });

  factory NoteBackground.fromJson(Map<String, dynamic> json) {
    return NoteBackground(
      type: BackgroundType.values.firstWhere(
            (e) => e.toString() == 'BackgroundType.${json['type']}',
      ),
      assetPath: json['assetPath'] as String?,
      opacity: json['opacity'] as double?,
      isTileable: json['isTileable'] as bool? ?? false,
      textColor: Color(json['textColor'] as int? ?? 0xFF000000),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'assetPath': assetPath,
      'opacity': opacity,
      'isTileable': isTileable,
      'textColor': textColor.value,
    };
  }

  // 预设背景
  static const NoteBackground defaultBackground = NoteBackground(
    type: BackgroundType.none,
    textColor: Colors.black,
  );

  static const NoteBackground cloudBackground = NoteBackground(
    type: BackgroundType.preset,
    assetPath: 'assets/images/cloud_pattern.png',
    isTileable: true,
    textColor: Color(0xFF2F4F4F),  // Dark Slate Gray
  );

  static const NoteBackground snowBackground = NoteBackground(
    type: BackgroundType.preset,
    assetPath: 'assets/images/snow_pattern.png',
    isTileable: true,
    textColor: Color(0xFF1C3D73),  // 更新为指定的深蓝色
  );

  static const NoteBackground bananaBackground = NoteBackground(
    type: BackgroundType.preset,
    assetPath: 'assets/images/banana_pattern.png',
    isTileable: true,
    textColor: Color(0xFF629970),  // 更新为指定的绿色
  );

  // 复制并修改背景属性
  NoteBackground copyWith({
    BackgroundType? type,
    String? assetPath,
    double? opacity,
    bool? isTileable,
    Color? textColor,
  }) {
    return NoteBackground(
      type: type ?? this.type,
      assetPath: assetPath ?? this.assetPath,
      opacity: opacity ?? this.opacity,
      isTileable: isTileable ?? this.isTileable,
      textColor: textColor ?? this.textColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NoteBackground &&
        other.type == type &&
        other.assetPath == assetPath &&
        other.opacity == opacity &&
        other.isTileable == isTileable &&
        other.textColor == textColor;
  }

  @override
  int get hashCode => Object.hash(
        type,
        assetPath,
        opacity,
        isTileable,
        textColor,
      );
}
