// lib/services/share/constants/share_constants.dart
/// 分享功能相关的常量配置
class ShareConstants {
  /// 图片尺寸相关常量
  static const ImageDimensions dimensions = ImageDimensions();
  /// 布局相关常量
  static const Layout layout = Layout();
  /// 文字排版相关常量
  static const Typography typography = Typography();
  /// 间距相关常量
  static const Spacing spacing = Spacing();
  /// 分割线相关常量
  static const Divider divider = Divider();
  /// 底部区域相关常量
  static const BottomArea bottomArea = BottomArea();
}

/// 分享图片的尺寸配置
class ImageDimensions {
  const ImageDimensions();
  /// 分享图片的宽度，单位像素
  double get width => 1200.0;
  /// 分享图片的最小高度，单位像素
  double get minHeight => 700.0;
}

/// 布局相关的配置
class Layout {
  const Layout();
  /// 水平方向的内边距，单位像素
  double get horizontalPadding => 80.0;
  /// 垂直方向的内边距，单位像素
  double get verticalPadding => 80.0;
  /// 圆角大小，单位像素
  double get borderRadius => 12.0;
}

/// 文字排版相关的配置
class Typography {
  const Typography();
  /// 标题文字大小，单位像素
  double get titleFontSize => 48.0;
  /// 内容文字大小，单位像素
  double get contentFontSize => 32.0;
  /// 水印文字大小，单位像素
  double get watermarkFontSize => 24.0;
  /// 内容文字的行高倍数
  double get contentLineHeight => 1.6;
  /// 水印文字的字间距
  double get watermarkLetterSpacing => 0.3;
}

/// 间距相关的配置
class Spacing {
  const Spacing();
  /// 标题底部间距，单位像素
  double get titleBottomSpacing => 40.0;
  /// 内容底部间距，单位像素
  double get contentBottomSpacing => 40.0;
  /// 分割线底部间距，单位像素
  double get dividerBottomSpacing => 20.0;
}

/// 分割线相关的配置
class Divider {
  const Divider();
  /// 分割线高度，单位像素
  double get height => 0.5;
  /// 分割线透明度，取值范围 0.0-1.0
  double get opacity => 0.3;
}

/// 底部区域相关的配置
class BottomArea {
  const BottomArea();
  /// 底部区域高度，单位像素
  double get height => 60.0;
  /// 底部区域内边距，单位像素
  double get padding => 60.0;
}

