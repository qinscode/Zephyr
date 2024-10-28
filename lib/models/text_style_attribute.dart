class TextStyleAttribute {
  final bool isHighlight;
  final bool isBold;
  final int? headerLevel; // 1-3 表示 H1-H3,null 表示普通文本
  final Color? highlightColor;

  const TextStyleAttribute({
    this.isHighlight = false,
    this.isBold = false,
    this.headerLevel,
    this.highlightColor,
  });

  Map<String, dynamic> toJson() {
    return {
      'isHighlight': isHighlight,
      'isBold': isBold,
      'headerLevel': headerLevel,
      'highlightColor': highlightColor?.value,
    };
  }

  factory TextStyleAttribute.fromJson(Map<String, dynamic> json) {
    return TextStyleAttribute(
      isHighlight: json['isHighlight'] ?? false,
      isBold: json['isBold'] ?? false,
      headerLevel: json['headerLevel'],
      highlightColor: json['highlightColor'] != null 
          ? Color(json['highlightColor']) 
          : null,
    );
  }

  TextStyleAttribute copyWith({
    bool? isHighlight,
    bool? isBold,
    int? headerLevel,
    Color? highlightColor,
  }) {
    return TextStyleAttribute(
      isHighlight: isHighlight ?? this.isHighlight,
      isBold: isBold ?? this.isBold,
      headerLevel: headerLevel ?? this.headerLevel,
      highlightColor: highlightColor ?? this.highlightColor,
    );
  }
}
