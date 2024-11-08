#!/bin/bash

# 定义应用名称和图标文件路径
APP_NAME="Zephyr"
ICON_NAME="zephyr"
ICON_PNG="app_icon.png"
ICON_ICNS="assets/$ICON_NAME.icns"

# 定义输出目录和 .dmg 文件路径
OUTPUT_DIR="build/macos"  # 指定输出目录，例如 "output" 文件夹
DMG_FILE="$OUTPUT_DIR/$APP_NAME.dmg"

# 创建输出目录（如果不存在）
mkdir -p "$OUTPUT_DIR"

# Step 0: 清理之前的构建
echo "Cleaning previous build..."
flutter clean

# Step 1: 构建 Flutter macOS 应用
echo "Building macOS app..."
flutter build macos --release

# Step 2: 检查 .icns 文件是否存在，如果不存在则生成
if [ ! -f "$ICON_ICNS" ]; then
    echo "Generating .icns file from $ICON_PNG..."

    # 创建 .iconset 文件夹
    mkdir "$ICON_NAME.iconset"

    # 生成不同尺寸的 PNG 文件
    sips -z 16 16     "$ICON_PNG" --out "$ICON_NAME.iconset/icon_16x16.png"
    sips -z 32 32     "$ICON_PNG" --out "$ICON_NAME.iconset/icon_16x16@2x.png"
    sips -z 32 32     "$ICON_PNG" --out "$ICON_NAME.iconset/icon_32x32.png"
    sips -z 64 64     "$ICON_PNG" --out "$ICON_NAME.iconset/icon_32x32@2x.png"
    sips -z 128 128   "$ICON_PNG" --out "$ICON_NAME.iconset/icon_128x128.png"
    sips -z 256 256   "$ICON_PNG" --out "$ICON_NAME.iconset/icon_128x128@2x.png"
    sips -z 256 256   "$ICON_PNG" --out "$ICON_NAME.iconset/icon_256x256.png"
    sips -z 512 512   "$ICON_PNG" --out "$ICON_NAME.iconset/icon_256x256@2x.png"
    sips -z 512 512   "$ICON_PNG" --out "$ICON_NAME.iconset/icon_512x512.png"
    sips -z 1024 1024 "$ICON_PNG" --out "$ICON_NAME.iconset/icon_512x512@2x.png"

    # 转换为 .icns 文件
    iconutil -c icns "$ICON_NAME.iconset" -o "$ICON_ICNS"

    # 删除 .iconset 文件夹
    rm -rf "$ICON_NAME.iconset"
fi

# Step 3: 创建 appdmg.json 配置文件
echo "Creating appdmg.json configuration..."
cat > appdmg.json <<EOL
{
  "title": "$APP_NAME",
  "icon": "$ICON_ICNS",
  "contents": [
    { "x": 448, "y": 344, "type": "link", "path": "/Applications" },
    { "x": 192, "y": 344, "type": "file", "path": "build/macos/Build/Products/Release/$APP_NAME.app" }
  ]
}
EOL

# Step 4: 使用 appdmg 工具生成 .dmg 文件
echo "Packaging $APP_NAME into $DMG_FILE..."
appdmg appdmg.json "$DMG_FILE"

# 清理 appdmg.json 文件
rm appdmg.json

echo "Build and packaging complete! $DMG_FILE generated."