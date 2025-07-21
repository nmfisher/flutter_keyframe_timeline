import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/src/model/src/animation_track.dart';
import 'package:flutter_keyframe_timeline/src/model/src/animation_track_group.dart';
import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/track_groups/animation_track_group/track_group_keyframes_widget.dart';
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
      builder: (_, pixelsPerFrame, __) => ValueListenableBuilder(
        valueListenable: widget.controller.trackGroups,
        builder: (_, groups, __) => VBox(
          children: groups
              .map(
                (group) => TrackGroupKeyframesWidget(
                  group: group,
                  controller: widget.controller,
                  pixelsPerFrame: pixelsPerFrame,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

