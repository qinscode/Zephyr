// 背景类型枚举
enum BackgroundType {
  none,      // 无背景
  preset,    // 预设背景
  custom,    // 自定义背景
}

// 背景类
class NoteBackground {
  final BackgroundType type;
  final String? assetPath;  // 预设背景的资源路径
  final String? customImagePath;  // 自定义背景图片路径
  final double? opacity;  // 背景透明度

  const NoteBackground({
    required this.type,
    this.assetPath,
    this.customImagePath,
    this.opacity = 1.0,
  });

  factory NoteBackground.fromJson(Map<String, dynamic> json) {
    return NoteBackground(
      type: BackgroundType.values.firstWhere(
        (e) => e.toString() == 'BackgroundType.${json['type']}',
      ),
      assetPath: json['assetPath'] as String?,
      customImagePath: json['customImagePath'] as String?,
      opacity: json['opacity'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'assetPath': assetPath,
      'customImagePath': customImagePath,
      'opacity': opacity,
    };
  }

  // 预设背景
  static const NoteBackground defaultBackground = NoteBackground(
    type: BackgroundType.none,
  );

  static const NoteBackground paperBackground = NoteBackground(
    type: BackgroundType.preset,
    assetPath: 'assets/images/paper_texture.png',
  );

  static const NoteBackground gridBackground = NoteBackground(
    type: BackgroundType.preset,
    assetPath: 'assets/images/grid_pattern.png',
  );

  static const NoteBackground linesBackground = NoteBackground(
    type: BackgroundType.preset,
    assetPath: 'assets/images/lines_pattern.png',
  );

  // 创建自定义背景
  static NoteBackground custom(String imagePath) => NoteBackground(
    type: BackgroundType.custom,
    customImagePath: imagePath,
  );

  // 复制并修改背景属性
  NoteBackground copyWith({
    BackgroundType? type,
    String? assetPath,
    String? customImagePath,
    double? opacity,
  }) {
    return NoteBackground(
      type: type ?? this.type,
      assetPath: assetPath ?? this.assetPath,
      customImagePath: customImagePath ?? this.customImagePath,
      opacity: opacity ?? this.opacity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NoteBackground &&
        other.type == type &&
        other.assetPath == assetPath &&
        other.customImagePath == customImagePath &&
        other.opacity == opacity;
  }

  @override
  int get hashCode => Object.hash(type, assetPath, customImagePath, opacity);
}
