import 'package:flutter/material.dart';

// Your UpwardArcClipper remains the same
class UpwardArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.3); // Start higher on the left
    path.quadraticBezierTo(
        size.width / 2, -size.height * 0.1, // Control point above for upward curve
        size.width, size.height * 0.3);     // End higher on the right
    path.lineTo(size.width, size.height);    // Line to bottom-right
    path.lineTo(0, size.height);             // Line to bottom-left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class ReusableArcBackground extends StatelessWidget {
  final Color arcColor; // The color to fill "beyond the arc"
  final double arcHeight;
  final Widget? child; // Optional child to display within the clipped area (above the arc color)

  const ReusableArcBackground({
    super.key,
    required this.arcColor,
    this.arcHeight = 100.0, // Default height, can be overridden
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // This container is the color that appears "beyond the arc"
        Container(
          height: arcHeight, // Use the provided or default arcHeight
          width: double.infinity,
          color: arcColor,
        ),
        // The ClipPath creates the arc.
        // The child (if any) or a default container is placed here.
        ClipPath(
          clipper: UpwardArcClipper(),
          child: Container(
            height: arcHeight, // Match the height
            width: double.infinity,
            // The color of this container will be the area "inside" the arc.
            // Typically, this would be your page's background color or transparent
            // if you want the arcColor to show through directly,
            // or you can place a child widget here.
            color: child == null ? Theme.of(context).scaffoldBackgroundColor : Colors.transparent,
            child: child,
          ),
        ),
      ],
    );
  }
}