import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';

class TimelineBackground extends StatelessWidget {
  final TimelineController controller;
  final Color tickColor;

  const TimelineBackground({super.key, required this.controller, required this.tickColor});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.pixelsPerFrame,
      builder: (_, pixelsPerFrame, __) => CustomPaint(
        willChange: true,
        painter: TimelineTickPainter(
          maxFrames: controller.maxFrames.value,
          minorTickInterval: 10,
          majorTickInterval: 60,
          tickColor: tickColor,
          // darkNeonTheme.colors[$token.color.onSurface] ??
          //     Colors.white,
          pixelsPerFrame: pixelsPerFrame,
        ),
      ),
    );
  }
}

class TimelineTickPainter extends CustomPainter {
  final double xOffset = 0.0;
  final int maxFrames;
  final int pixelsPerFrame;
  final int minorTickInterval;
  final int majorTickInterval;
  final Color tickColor;

  TimelineTickPainter({
    required this.maxFrames,
    required this.pixelsPerFrame,
    required this.minorTickInterval,
    required this.majorTickInterval,
    required this.tickColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    
    final minorPaint = Paint()
      ..color = tickColor.withOpacity(0.1)
      ..strokeWidth = 1;

    final majorPaint = Paint()
      ..color = tickColor.withOpacity(0.3)
      ..strokeWidth = 2;

    final textPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Draw vertical lines for all minor ticks
    for (int frame = 0; frame <= maxFrames; frame += minorTickInterval) {
      final x = xOffset + (frame * pixelsPerFrame).toDouble();
      final paint = frame % majorTickInterval == 0 ? majorPaint : minorPaint;

      // Calculate the starting y position for the line
      final textStartY = 16.0; // Leave space for text

      // Draw vertical line starting below the text
      canvas.drawLine(Offset(x, textStartY), Offset(x, size.height), paint);

      // Only draw frame numbers for major ticks
      if (frame % majorTickInterval == 0) {
        textPainter.text = TextSpan(
          text: frame.toString(),
          style: TextStyle(color: tickColor, fontSize: 10),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, 2));
      }
    }
  }

  @override
  bool shouldRepaint(TimelineTickPainter oldDelegate) =>
      maxFrames != oldDelegate.maxFrames ||
      minorTickInterval != oldDelegate.minorTickInterval ||
      majorTickInterval != oldDelegate.majorTickInterval ||
      tickColor != oldDelegate.tickColor;
}
