import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/track_groups/keyframe/keyframe_display_widget.dart';
import 'package:mix/mix.dart';

class TrackKeyframesWidget extends StatelessWidget {
  final AnimationTrack track;
  final TimelineController controller;
  final ScrollController scrollController;

  const TrackKeyframesWidget({
    super.key,
    required this.track,
    required this.controller,
    required this.scrollController
    // required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: track.keyframes,
      builder: (_, keyframes, __) => ZBox(
        style: Style(
          // $box.width(width),
        ),
        children: keyframes.values.map((kf) {
          return ValueListenableBuilder(
            valueListenable: kf.frameNumber,
            builder: (_, frameNumber, __) {
              return ValueListenableBuilder(
                valueListenable: controller.selected,
                builder: (_, selected, __) {
                  var isSelected = selected.contains(kf);
                  return KeyframeDisplayWidget(
                    pixelsPerFrame: controller.pixelsPerFrame.value,
                    frameNumber: frameNumber,
                    isSelected: isSelected,
                  );
                },
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
