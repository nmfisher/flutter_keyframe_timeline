import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/src/model/src/animation_track.dart';
import 'package:flutter_keyframe_timeline/src/model/src/animation_track_group.dart';
import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/track_groups/keyframe/keyframe_display_widget.dart';
import 'package:mix/mix.dart';

// A vertical list of keyframe tracks
class KeyframeTrackListWidget extends StatefulWidget {
  final TimelineController controller;

  const KeyframeTrackListWidget({super.key, required this.controller});

  @override
  State<KeyframeTrackListWidget> createState() => _TrackGroupWidgetState();
}

class _TrackGroupWidgetState extends State<KeyframeTrackListWidget> {
  @override
  void didUpdateWidget(KeyframeTrackListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller.pixelsPerFrame,
      builder: (_, pixelsPerFrame, __) =>
      ValueListenableBuilder(
      valueListenable: widget.controller.trackGroups,
      builder: (_, groups, __) =>
       VBox(
        children: groups
            .map(
              (group) => _SingleObjectKeyframeTracksWidget(
                group: group,
                controller: widget.controller,
                pixelsPerFrame: pixelsPerFrame,
              ),
            )
            .toList(),
      ),
    ));
  }
}

class _SingleObjectKeyframeTracksWidget extends StatelessWidget {
  final TimelineController controller;
  final AnimationTrackGroup group;
  final int pixelsPerFrame;

  const _SingleObjectKeyframeTracksWidget({
    super.key,
    required this.controller,
    required this.group,
    required this.pixelsPerFrame,
  });

  Widget _channel(AnimationTrack track) {
    return ValueListenableBuilder(
      valueListenable: track.keyframes,
      builder: (_, keyframes, __) => ZBox(
        style: Style($box.color.orange(), $box.width(999)),
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

  Widget _allKeyframes() {
    return ZBox(
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
    return Text("KEYFRAMES ${group.displayName.value}");
    return VBox(
      key: Key("${group.hashCode}_keyframe_tracks"),
      style: Style(
        $flex.mainAxisSize.min(),
        $flex.crossAxisAlignment.start(),
        // $box.height(
        //   isExpanded
        //       ? TimelineStyle.lineHeight * 4
        //       : TimelineStyle.lineHeight,
        // ),
      ),
      children: [_allKeyframes(), ...group.tracks.map(_channel).toList()],
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
