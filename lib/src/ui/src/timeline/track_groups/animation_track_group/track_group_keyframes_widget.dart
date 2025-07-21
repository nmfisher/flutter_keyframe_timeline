import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/src/model/src/animation_track.dart';
import 'package:flutter_keyframe_timeline/src/model/src/animation_track_group.dart';
import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/track_groups/keyframe/keyframe_display_widget.dart';
import 'package:mix/mix.dart';


class TrackGroupKeyframesWidget extends StatelessWidget {
  final TimelineController controller;
  final AnimationTrackGroup group;
  final int pixelsPerFrame;

  const TrackGroupKeyframesWidget({
    super.key,
    required this.controller,
    required this.group,
    required this.pixelsPerFrame,
  });

  Widget _channel(double width, AnimationTrack track) {
    return ValueListenableBuilder(
      valueListenable: track.keyframes,
      builder: (_, keyframes, __) => ZBox(
        style: Style(
          $box.border.bottom(color: Colors.black),
          $box.width(width),
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
                    pixelsPerFrame: pixelsPerFrame,
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

  Widget _allKeyframes(double width) {
    return ZBox(
      style: Style($box.color.grey.withOpacity(0.5), $box.width(width)),
      children: group
          .getKeyframesAtFrame(controller.currentFrame.value)
          .map(
            (kf) => KeyframeDisplayWidget(
              pixelsPerFrame: pixelsPerFrame,
              frameNumber: kf.frameNumber.value,
              isSelected: false,
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return ValueListenableBuilder(
          valueListenable: controller.expanded,
          builder: (_, expanded, __) {
            final isExpanded = expanded.contains(group);
            return VBox(
              key: Key("${group.hashCode}_keyframe_tracks"),
              style: Style(
                $flex.mainAxisSize.min(),
                $flex.crossAxisAlignment.start(),

              ),
              children: [
                _allKeyframes(constraints.maxWidth),
                if (isExpanded)
                  ...group.tracks
                      .map((track) => _channel(constraints.maxWidth, track))
                      .toList(),
              ],
            );
          },
        );
      },
    );
  }
}

// GestureDetector(
//         onTapUp: (event) {
//           _focusNode.requestFocus();
//           final RenderBox parentBox = context.findRenderObject() as RenderBox;
//           final localPosition = parentBox.globalToLocal(event.globalPosition);

//           var currentFrame =
//               ((localPosition.dx - controller.trackNameWidth) /
//                       controller.pixelsPerFrame.value)
//                   .floor();
//           if (currentFrame >= 0) {
//             controller.setCurrentFrame(currentFrame);
//           }
//         },
//         // vertical ScrollView when track are expanded
//         child:
