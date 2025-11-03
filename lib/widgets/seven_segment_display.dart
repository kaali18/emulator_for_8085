import 'package:flutter/material.dart';

/// Seven Segment Display Widget
/// Displays a single digit/character using a 7-segment LED display pattern
class SevenSegment extends StatelessWidget {
  final String value;

  const SevenSegment({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final segments = _getSegments(value.toUpperCase());

    return Container(
      width: 32,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: CustomPaint(
        painter: SevenSegmentPainter(segments),
      ),
    );
  }

  /// Maps characters to their 7-segment representation
  /// Returns a list of 7 booleans representing which segments are lit
  List<bool> _getSegments(String char) {
    const Map<String, List<bool>> segmentMap = {
      '0': [true, true, true, true, true, true, false],
      '1': [false, true, true, false, false, false, false],
      '2': [true, true, false, true, true, false, true],
      '3': [true, true, true, true, false, false, true],
      '4': [false, true, true, false, false, true, true],
      '5': [true, false, true, true, false, true, true],
      '6': [true, false, true, true, true, true, true],
      '7': [true, true, true, false, false, false, false],
      '8': [true, true, true, true, true, true, true],
      '9': [true, true, true, true, false, true, true],
      'A': [true, true, true, false, true, true, true],
      'B': [false, false, true, true, true, true, true],
      'C': [true, false, false, true, true, true, false],
      'D': [false, true, true, true, true, false, true],
      'E': [true, false, false, true, true, true, true],
      'F': [true, false, false, false, true, true, true],
      '-': [false, false, false, false, false, false, true],
      'R': [true, false, false, false, true, false, true],
      'G': [true, false, true, true, true, true, false],
      ' ': [false, false, false, false, false, false, false],
    };

    return segmentMap[char] ?? [false, false, false, false, false, false, false];
  }
}

/// Custom painter for rendering the 7-segment display
class SevenSegmentPainter extends CustomPainter {
  final List<bool> segments;

  SevenSegmentPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for illuminated segments
    final onPaint = Paint()
      ..color = const Color(0xFFFF1744)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2.5);

    // Paint for off segments
    final offPaint = Paint()
      ..color = const Color(0xFF4A0404).withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final thickness = 6.0;

    // Define all 7 segment paths
    // Segment layout:
    //     A
    //   F   B
    //     G
    //   E   C
    //     D
    final paths = [
      _getHorizontalPath(w * 0.1, 0, w * 0.8, thickness), // A (top)
      _getVerticalPath(w - thickness, h * 0.05, h * 0.4, thickness), // B (top-right)
      _getVerticalPath(w - thickness, h * 0.55, h * 0.4, thickness), // C (bottom-right)
      _getHorizontalPath(w * 0.1, h - thickness, w * 0.8, thickness), // D (bottom)
      _getVerticalPath(0, h * 0.55, h * 0.4, thickness), // E (bottom-left)
      _getVerticalPath(0, h * 0.05, h * 0.4, thickness), // F (top-left)
      _getHorizontalPath(w * 0.1, h / 2 - thickness / 2, w * 0.8, thickness), // G (middle)
    ];

    // Draw each segment
    for (int i = 0; i < 7; i++) {
      canvas.drawPath(paths[i], segments[i] ? onPaint : offPaint);
    }
  }

  /// Creates a horizontal segment path
  Path _getHorizontalPath(double x, double y, double width, double thickness) {
    return Path()
      ..moveTo(x + thickness * 0.5, y)
      ..lineTo(x + width - thickness * 0.5, y)
      ..lineTo(x + width, y + thickness / 2)
      ..lineTo(x + width - thickness * 0.5, y + thickness)
      ..lineTo(x + thickness * 0.5, y + thickness)
      ..lineTo(x, y + thickness / 2)
      ..close();
  }

  /// Creates a vertical segment path
  Path _getVerticalPath(double x, double y, double height, double thickness) {
    return Path()
      ..moveTo(x + thickness / 2, y)
      ..lineTo(x + thickness, y + thickness * 0.5)
      ..lineTo(x + thickness, y + height - thickness * 0.5)
      ..lineTo(x + thickness / 2, y + height)
      ..lineTo(x, y + height - thickness * 0.5)
      ..lineTo(x, y + thickness * 0.5)
      ..close();
  }

  @override
  bool shouldRepaint(SevenSegmentPainter oldDelegate) => true;
}
