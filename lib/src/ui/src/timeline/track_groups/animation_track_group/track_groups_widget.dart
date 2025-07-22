import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/track_groups/animation_track_group/track_group_widget.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/track_groups/keyframe/keyframe_display_widget.dart';
import 'package:mix/mix.dart';

class TrackGroupsWidget extends StatelessWidget {
  final TimelineController controller;
  final ScrollController horizontalScrollController;
  final double trackNameWidth;
  final KeyframeIconBuilder keyframeIconBuilder;

  const TrackGroupsWidget({
    super.key,
    required this.controller,
    required this.horizontalScrollController,
    required this.trackNameWidth,
    required this.keyframeIconBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: ValueListenableBuilder(
        valueListenable: controller.trackGroups,
        builder: (_, groups, __) => VBox(
          key: ObjectKey(controller.trackGroups),
          style: Style($flex.crossAxisAlignment.start()),
          children: groups
              .asMap()
              .map(
                (idx, group) => MapEntry(
                  idx,
                  TrackGroupWidget(
                    key: ObjectKey(group),
                    group: group,
                    index: idx,
                    controller: controller,
                    trackNameWidth: trackNameWidth,
                    scrollController: horizontalScrollController,
                    keyframeIconBuilder: keyframeIconBuilder,
                  ),
                ),
              )
              .values
              .cast<Widget>()
              .toList(),
        ),
      ),
    );

  }
}


  