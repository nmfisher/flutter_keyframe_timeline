import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';

class TimelineBackground extends StatefulWidget {
  final TimelineController controller;
  final ScrollController scrollController;
  final double trackNameWidth;
  final Color tickColor;
  final Widget inner;

  const TimelineBackground({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.tickColor,
    required this.inner,
    required this.trackNameWidth,
  });

  @override
  State<TimelineBackground> createState() => _TimelineBackgroundState();
}

class _TimelineBackgroundState extends State<TimelineBackground> {
  @override
  void initState() {
    super.initState();

    widget.scrollController.addListener(_onScrollUpdate);
  }

  void _onScrollUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller.pixelsPerFrame,
      builder: (_, pixelsPerFrame, __) => CustomPaint(
        willChange: false,
        painter: TimelineTickPainter(
          maxFrames: widget.controller.maxFrames.value,
          minorTickInterval: 10,
          majorTickInterval: 60,
          tickColor: widget.tickColor,
          trackNameWidth: widget.trackNameWidth,
          scrollOffset: widget.scrollController.hasClients
              ? widget.scrollController.offset
              : 0.0,
          // darkNeonTheme.colors[$token.color.onSurface] ??
          //     Colors.white,
          pixelsPerFrame: pixelsPerFrame,
        ),
        child: widget.inner,
      ),
    );
  }
}

class TimelineTickPainter extends CustomPainter {
  final double trackNameWidth;
  final double scrollOffset;
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
    required this.trackNameWidth,
    required this.scrollOffset
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

    final startFrame = (scrollOffset / pixelsPerFrame).floor();
    final endFrame = ((scrollOffset + size.width) / pixelsPerFrame).floor();

    final numFrames = endFrame - startFrame;

    // Draw vertical lines for all minor ticks
    for (int frame = startFrame; frame <= endFrame; frame++) {
      
      final x = trackNameWidth + ((frame - startFrame) * pixelsPerFrame).toDouble();
      
      if (frame % minorTickInterval == 0) {
        final paint = frame % majorTickInterval == 0 ? majorPaint : minorPaint;

        // Calculate the starting y position for the line
        final textStartY = 16.0; // Leave space for text

        // Draw vertical line starting below the text
        canvas.drawLine(Offset(x, textStartY), Offset(x, size.height), paint);
      }

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
