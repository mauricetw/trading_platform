import 'package:flutter/material.dart';
import 'dart:math' as math; // 用於 PI

class FullBottomConcaveAppBarShape extends ShapeBorder {
  final double curveHeight;    // 底部向內（上）彎曲的高度
  final double topCornerRadius; // AppBar 頂部兩個角的圓角 (可選)
  // 如果底部也是圓角，並且希望曲線從圓角開始，則需要更複雜的處理

  const FullBottomConcaveAppBarShape({
    this.curveHeight = 20.0,
    this.topCornerRadius = 0.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero; // 頂部切齊，無額外偏移

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final Path path = Path();
    final double topY = rect.top;
    final double bottomY = rect.bottom; // 曲線將基於這個 Y 值向上凹陷

    // 1. 左上角
    path.moveTo(rect.left + topCornerRadius, topY);

    // 2. 頂部直線
    path.lineTo(rect.right - topCornerRadius, topY);

    // 3. 右上角圓角
    if (topCornerRadius > 0) {
      path.arcToPoint(
        Offset(rect.right, topY + topCornerRadius),
        radius: Radius.circular(topCornerRadius),
        clockwise: true,
      );
    } else {
      path.lineTo(rect.right, topY);
    }

    // 4. 右側垂直線，直接到達右下角 (即曲線的終點)
    path.lineTo(rect.right, bottomY);

    // 5. 整個底部邊緣變為向內彎曲的二次貝塞爾曲線
    // 起點是右下角 (當前畫筆位置)，終點是左下角
    // 我們從右下角畫到左下角
    path.quadraticBezierTo(
        rect.center.dx,           // 控制點 X：底部中心
        bottomY - curveHeight,    // 控制點 Y：底部向上 curveHeight (形成向內凹陷)
        rect.left,                // 終點 X：左下角
        bottomY                   // 終點 Y：左下角 (回到 AppBar 的底部水平線)
    );

    // 6. 左側垂直線 (畫筆已在 rect.left, bottomY)
    path.lineTo(rect.left, topY + topCornerRadius);

    // 7. 左上角圓角
    if (topCornerRadius > 0) {
      path.arcToPoint(
        Offset(rect.left + topCornerRadius, topY),
        radius: Radius.circular(topCornerRadius),
        clockwise: true,
      );
    }
    // 如果沒有左上角圓角，moveTo 已經處理了起點，並且lineTo會正確連接

    path.close();
    return path;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return FullBottomConcaveAppBarShape(
      curveHeight: curveHeight * t,
      topCornerRadius: topCornerRadius * t,
    );
  }
}
