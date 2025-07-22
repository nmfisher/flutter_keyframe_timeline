import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/track_groups/keyframe/keyframe_display_widget.dart';

class TrackKeyframesWidget extends StatelessWidget {
  final AnimationTrack track;
  final TimelineController controller;
  final ScrollController scrollController;
  final KeyframeIconBuilder keyframeIconBuilder;

  const TrackKeyframesWidget({
    super.key,
    required this.track,
    required this.controller,
    required this.scrollController,
    required this.keyframeIconBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: track.keyframes,
      builder: (_, keyframes, __) => LayoutBuilder(
        builder: (context, constraints) {
          // Calculate the total width needed for all keyframes

          return SizedBox(
            height: constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : 50, // Fallback height
            child: Flow(
              clipBehavior: Clip.none,
              delegate: _KeyframeFlowDelegate(
                controller: controller,
                scrollController: scrollController,
                keyframes: keyframes.values.toList(),
              ),
              children: keyframes.values.map((kf) {
                    return ValueListenableBuilder(
                      valueListenable: controller.selected,
                      builder: (_, selected, __) {
                        var isSelected = selected.contains(kf);
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: KeyframeDisplayWidget(
                            pixelsPerFrame: controller.pixelsPerFrame.value,
                            frameNumber: kf.frameNumber.value,
                            isSelected: isSelected,
                            keyframeIconBuilder: keyframeIconBuilder,
                            onFrameNumberChanged: (int value) {
                              kf.setFrameNumber(value);
                            },
                          ),
                        );
                    
                  },
                );
              }).toList(),
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
  final List<dynamic> keyframes;

  _KeyframeFlowDelegate({
    required this.controller,
    required this.scrollController,
    required this.keyframes,
  }) : super(repaint: Listenable.merge([scrollController, ...keyframes.map((kf) => kf.frameNumber)]));

  @override
  void paintChildren(FlowPaintingContext context) {
    for (int i = 0; i < context.childCount; i++) {
      final keyframe = keyframes[i];
      final frameNumber = keyframe.frameNumber.value;
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
