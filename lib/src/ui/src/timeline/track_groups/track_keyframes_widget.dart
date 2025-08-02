import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart' hide Clip;

import 'keyframe/keyframe_display_widget.dart';

import 'package:timeline_dart/timeline_dart.dart' as dart;

class TrackKeyframesWidget extends StatelessWidget {
  final FlutterKeyframeTrack track;
  final TimelineController controller;
  final ScrollController scrollController;
  final KeyframeIconBuilder keyframeIconBuilder;
  final KeyframeConnectionStyle connectionStyle;

  const TrackKeyframesWidget({
    super.key,
    required this.track,
    required this.controller,
    required this.scrollController,
    required this.keyframeIconBuilder,
    required this.connectionStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: track.keyframesListenable,
      builder: (_, keyframes, __) => LayoutBuilder(
        builder: (context, constraints) {
          // Calculate the total width needed for all keyframes

          return SizedBox(
            height: constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : 50, // Fallback height
            child: CustomPaint(
              painter: _KeyframeConnectionPainter(
                keyframes: keyframes,
                controller: controller,
                scrollController: scrollController,
                connectionStyle: connectionStyle,
              ),
              child: Flow(
                clipBehavior: Clip.none,
                delegate: _KeyframeFlowDelegate(
                  controller: controller,
                  scrollController: scrollController,
                  keyframes: track.keyframesListenable,
                ),
                children: keyframes.map((kf) {
                  return ValueListenableBuilder(
                    valueListenable: controller.selected,
                    builder: (_, selected, __) {
                      var isSelected = selected.contains(kf);
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: KeyframeDisplayWidget(
                          pixelsPerFrame: controller.pixelsPerFrame.value,
                          frameNumber: kf.frameNumber,
                          isSelected: isSelected,
                          keyframeIconBuilder: keyframeIconBuilder,
                          onDelete: () {
                            track.removeKeyframeAt(kf.frameNumber);
                          },
                          onTap: () {
                            controller.select(
                              kf,
                              track,
                              append: HardwareKeyboard.instance.isShiftPressed,
                            );
                          },
                          onFrameNumberChanged: (value) {
                            controller.moveSelectedKeyframes(value.frameDelta);
                          },
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _KeyframeFlowDelegate extends FlowDelegate {
  final TimelineController controller;
  final ScrollController scrollController;
  late final List<dart.Keyframe> keyframes;

  _KeyframeFlowDelegate({
    required this.controller,
    required this.scrollController,
    required ValueListenable<List<dart.Keyframe>> keyframes,
  }) : super(
          repaint: Listenable.merge([
            scrollController,
            controller.currentFrame,
            controller.maxFrames,
            controller.pixelsPerFrame,
            keyframes,
          ]),
        ) {
    this.keyframes = keyframes.value.toList();
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    // Draw keyframes
    for (int i = 0; i < context.childCount; i++) {
      final keyframe = keyframes[i];
      final frameNumber = keyframe.frameNumber;
      final pixelsPerFrame = controller.pixelsPerFrame.value;

      final xPosition =
          (frameNumber * pixelsPerFrame) - scrollController.offset;
      if (xPosition >= 0 && xPosition <= context.size.width) {
        context.paintChild(
          i,
          transform: Matrix4.translationValues(xPosition, 0, 0),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _KeyframeFlowDelegate oldDelegate) {
    return true;
  }
}

class _KeyframeConnectionPainter extends CustomPainter {
  final List<dart.Keyframe> keyframes;
  final TimelineController controller;
  final ScrollController scrollController;
  final KeyframeConnectionStyle connectionStyle;

  _KeyframeConnectionPainter({
    required this.keyframes,
    required this.controller,
    required this.scrollController,
    required this.connectionStyle,
  }) : super(
          repaint: Listenable.merge([
            scrollController,
            controller.currentFrame,
            controller.maxFrames,
            controller.pixelsPerFrame,
            controller.selected,
          ]),
        );

  @override
  void paint(Canvas canvas, Size size) {
    if (!connectionStyle.showConnections || keyframes.length <= 1) {
      return;
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sortedKeyframes = List<dart.Keyframe>.from(keyframes)
      ..sort((a, b) => a.frameNumber.compareTo(b.frameNumber));
    
    final selectedKeyframes = controller.selected.value;
    final pixelsPerFrame = controller.pixelsPerFrame.value;

    for (int i = 0; i < sortedKeyframes.length - 1; i++) {
      final currentKeyframe = sortedKeyframes[i];
      final nextKeyframe = sortedKeyframes[i + 1];
      
      final startX = (currentKeyframe.frameNumber * pixelsPerFrame) - scrollController.offset;
      final endX = (nextKeyframe.frameNumber * pixelsPerFrame) - scrollController.offset;
      
      // Only draw line if at least part of it is visible
      if ((endX >= 0 && startX <= size.width) || 
          (startX >= 0 && endX <= size.width)) {
        final isCurrentSelected = selectedKeyframes.contains(currentKeyframe);
        final isNextSelected = selectedKeyframes.contains(nextKeyframe);
        final isSelected = isCurrentSelected || isNextSelected;
        
        paint.color = isSelected ? connectionStyle.selectedLineColor : connectionStyle.lineColor;
        paint.strokeWidth = isSelected ? connectionStyle.selectedLineWidth : connectionStyle.lineWidth;
        
        final y = size.height / 2;
        canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _KeyframeConnectionPainter oldDelegate) {
    return true;
  }
}
