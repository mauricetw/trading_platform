import 'package:flutter/material.dart';
import 'dart:math' as math; // For PI

// 自定義 Clipper 來創建上半部分為橢圓弧形的形狀
class SemiEllipseClipper extends CustomClipper<Path> {
  final double arcHeightFactor; // 控制橢圓弧形的高度因子，0.0 到 1.0

  SemiEllipseClipper({this.arcHeightFactor = 0.5});

  @override
  Path getClip(Size size) {
    final Path path = Path();
    // 橢圓弧形的高度
    final double arcHeight = size.height * arcHeightFactor;

    // 起始點 (左下角)
    path.lineTo(0, size.height - arcHeight); // 從 (0,0) 到左邊弧線開始前的直線部分

    // 繪製上半部分的橢圓弧線
    // 使用 quadraticBezierTo 或 arcToPoint
    // 這裡我們用一個簡化的方式，使用 arcToPoint 繪製一個橢圓的一部分
    // Rect 的 top 應該是 size.height - 2 * arcHeight 來讓弧線的頂點在期望位置
    // 但更簡單的是直接控制橢圓的 bounding box
    Rect ovalRect = Rect.fromLTWH(0, size.height - 2 * arcHeight, size.width, 2 * arcHeight);
    path.arcTo(ovalRect, math.pi, -math.pi, false); // 從180度掃過-180度 (即上半橢圓)

    // 連接到右下角
    path.lineTo(size.width, size.height - arcHeight); // 弧線結束點到右邊直線部分
    path.lineTo(size.width, 0); // 右下角回到 (width, 0) -- 這裡應該是 path.lineTo(size.width, size.height); path.lineTo(0, size.height);
    // 如果是要裁剪頂部為弧形，底部為矩形
    // 修正：我們是要頂部為弧線，按鈕的底部是屏幕底部
    path.moveTo(0, size.height); // 左下角
    path.lineTo(0, arcHeight); // 左邊直線部分
    // path.quadraticBezierTo(size.width / 2, 0, size.width, arcHeight); // 頂部弧線 (二次貝塞爾曲線)
    // 或者使用 arcToPoint 創建更精確的橢圓弧
    // Rect ovalRect = Rect.fromLTWH(0, 0, size.width, arcHeight * 2);
    // path.arcTo(ovalRect, math.pi, math.pi, false); // 這樣會畫一個完整的上半橢圓

    // 重新思考路徑，目標是：頂部是橢圓弧線，左右是垂直線，底部是水平線
    path.moveTo(0, size.height); // 左下角
    path.lineTo(size.width, size.height); // 右下角
    path.lineTo(size.width, arcHeight); // 右上角直線部分結束點

    // 頂部橢圓弧線
    // 控制點 x: size.width / 2, y: 0 (弧線最高點)
    path.quadraticBezierTo(size.width / 2, 0, 0, arcHeight);
    path.close(); // 閉合路徑

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


class SemiEllipseSwipeUpPanel extends StatefulWidget {
  final double collapsedHeight;
  final Widget collapsedChild;
  final Widget expandedChild;
  final Duration animationDuration;
  final Color? panelBackgroundColor; // 面板整體的背景色
  final Color? collapsedButtonColor; // 底部按鈕部分的特定顏色

  const SemiEllipseSwipeUpPanel({
    super.key,
    this.collapsedHeight = 80.0, // 橢圓形按鈕可能需要更高一些
    required this.collapsedChild,
    required this.expandedChild,
    this.animationDuration = const Duration(milliseconds: 300),
    this.panelBackgroundColor,
    this.collapsedButtonColor,
  });

  @override
  State<SemiEllipseSwipeUpPanel> createState() => _SemiEllipseSwipeUpPanelState();
}

class _SemiEllipseSwipeUpPanelState extends State<SemiEllipseSwipeUpPanel> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final topOffset = (1 - _animationController.value) * (screenHeight - widget.collapsedHeight);

        return Stack(
          children: [
            // 1. 可擴展的全屏內容區域 (expandedChild)
            if (_animationController.value > 0 || _isExpanded)
              Positioned(
                top: topOffset,
                left: 0,
                right: 0,
                height: screenHeight - topOffset,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy > 5) _togglePanel();
                  },
                  onVerticalDragEnd: (details) {
                    if (details.primaryVelocity != null && details.primaryVelocity! > 200) _togglePanel();
                  },
                  child: Container(
                    width: screenWidth,
                    color: widget.panelBackgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
                    child: _isExpanded || _animationController.isAnimating ? widget.expandedChild : const SizedBox.shrink(),
                  ),
                ),
              ),

            // 2. 底部可見的半橢圓按鈕部分 (collapsedChild)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: widget.collapsedHeight,
              child: GestureDetector(
                onTap: _togglePanel,
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy < -5) _togglePanel();
                },
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity != null && details.primaryVelocity! < -200) _togglePanel();
                },
                child: ClipPath( // 使用 ClipPath 進行裁剪
                  clipper: SemiEllipseClipper(arcHeightFactor: 0.8), // arcHeightFactor 控制弧度，可以調整
                  // 這裡的 arcHeightFactor 是相對於 collapsedHeight
                  child: Material( // 添加 Material 是為了點擊效果和可能的陰影
                    elevation: _isExpanded ? 0 : 5.0, // 陰影可以根據需要調整
                    color: widget.collapsedButtonColor ?? Colors.blueAccent, // 底部按鈕的顏色
                    shadowColor: Colors.black.withOpacity(0.5),
                    child: SizedBox( // SizedBox 確保 collapsedChild 在裁剪區域內正確佈局
                      width: screenWidth,
                      height: widget.collapsedHeight,
                      child: widget.collapsedChild,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}