import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/track_groups/animation_track_group/track_group_widget.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/timeline_style.dart';
import 'package:mix/mix.dart';

class TrackGroupsWidget extends StatefulWidget {
  final TimelineController controller;
  final ScrollController horizontalScrollController;
  final double trackNameWidth;
  final KeyframeIconBuilder keyframeIconBuilder;
  final KeyframeToggleIconBuilder? keyframeToggleIconBuilder;

  const TrackGroupsWidget({
    super.key,
    required this.controller,
    required this.horizontalScrollController,
    required this.trackNameWidth,
    required this.keyframeIconBuilder,
    this.keyframeToggleIconBuilder,
  });

  @override
  State<TrackGroupsWidget> createState() => _TrackGroupsWidgetState();
}

class _TrackGroupsWidgetState extends State<TrackGroupsWidget> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyUpEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.delete:
              widget.controller.deleteSelectedKeyframes();
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowLeft:
              widget.controller.setCurrentFrame(
                widget.controller.currentFrame.value - 1,
              );
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowRight:
              widget.controller.setCurrentFrame(
                widget.controller.currentFrame.value + 1,
              );
          }
        }

        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () {
          _focusNode.requestFocus();
          widget.controller.clearSelectedKeyframes();
        },
        child: ValueListenableBuilder(
          valueListenable: widget.controller.trackGroups,
          builder: (_, groups, __) => VBox(
            key: ObjectKey(widget.controller.trackGroups),
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
                      controller: widget.controller,
                      trackNameWidth: widget.trackNameWidth,
                      scrollController: widget.horizontalScrollController,
                      keyframeIconBuilder: widget.keyframeIconBuilder,
                      keyframeToggleIconBuilder:
                          widget.keyframeToggleIconBuilder,
                    ),
                  ),
                )
                .values
                .cast<Widget>()
                .toList(),
          ),
        ),
      ),
    );
  }
}
