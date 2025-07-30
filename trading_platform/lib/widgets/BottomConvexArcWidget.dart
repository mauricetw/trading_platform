// BottomConvexArcWidget.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class BottomConvexArcWidget extends StatelessWidget {
  final double barHeight;
  final double curveHeight;
  final Color backgroundColor;
  final Widget? child;

  const BottomConvexArcWidget({
    super.key,
    this.barHeight = 60.0,
    required this.curveHeight,
    this.backgroundColor = Colors.blue,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width, barHeight + curveHeight),
      painter: _BottomConvexArcPainter(
        color: backgroundColor,
        curveActualHeight: curveHeight,
        arcBaselineY: curveHeight,
        barBelowBaselineHeight: barHeight,
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: barHeight + curveHeight,
        child: Padding(
          padding: EdgeInsets.only(top: curveHeight),
          child: SizedBox(
            height: barHeight,
            child: child,
          ),
        ),
      ),
    );
  }
}

// _BottomConvexArcPainter 保持不變 (與方案3中的版本一致)
class _BottomConvexArcPainter extends CustomPainter {
  final Color color;
  final double curveActualHeight;
  final double arcBaselineY;
  final double barBelowBaselineHeight;

  _BottomConvexArcPainter({
    required this.color,
    required this.curveActualHeight,
    required this.arcBaselineY,
    required this.barBelowBaselineHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    final double w = size.width;
    final double totalPaintedHeight = arcBaselineY + barBelowBaselineHeight;
    path.moveTo(0, arcBaselineY);
    if (curveActualHeight > 0) {
      double radiusValue = ((w * w / 4) + (curveActualHeight * curveActualHeight)) / (2 * curveActualHeight);
      path.arcToPoint(Offset(w, arcBaselineY), radius: Radius.circular(radiusValue), clockwise: true);
    } else {
      path.lineTo(w, arcBaselineY);
    }
    path.lineTo(w, totalPaintedHeight);
    path.lineTo(0, totalPaintedHeight);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BottomConvexArcPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.curveActualHeight != curveActualHeight ||
        oldDelegate.arcBaselineY != arcBaselineY ||
        oldDelegate.barBelowBaselineHeight != barBelowBaselineHeight;
  }
}
