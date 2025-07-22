import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/src/model/model.dart';
import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/shared/expand_icon.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/track_groups/animation_track_group/track_keyframes_widget.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/track_groups/animation_track_group/track_visibility_widget.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/track_groups/animation_track_group/value_editor/animation_channel_editor_widget.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/timeline_style.dart';
import 'package:mix/mix.dart';

class TrackGroupWidget extends StatelessWidget {
  final TimelineController controller;
  final ScrollController scrollController;
  final AnimationTrackGroup group;

  final int index;
  final double trackNameWidth;
  final KeyframeIconBuilder keyframeIconBuilder;
  final KeyframeToggleIconBuilder? keyframeToggleIconBuilder;

  const TrackGroupWidget({
    super.key,
    required this.group,
    required this.controller,
    required this.scrollController,
    required this.index,
    required this.trackNameWidth,
    required this.keyframeIconBuilder,
    this.keyframeToggleIconBuilder,
  });

  Widget _groupName(bool isExpanded) {
    return ValueListenableBuilder(
      valueListenable: controller.active,
      builder: (_, active, __) {
        final isActive = active.contains(group);
        return HBox(
          children: [
            Expanded(
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (details) {
                  if (details.buttons & kPrimaryMouseButton ==
                      kPrimaryMouseButton) {
                    controller.setActive(group, true);
                  }
                },
                child: HBox(
                  children: [
                    CustomExpandIcon(
                      isExpanded: isExpanded,
                      isActive: isActive,
                      setExpanded: (expanded) {
                        controller.setExpanded(group, expanded);
                      },
                    ),
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: group.displayName,
                        builder: (_, displayName, __) => StyledText(
                          displayName,
                          style: Style(
                            $text.color.withOpacity(isActive ? 1.0 : 0.5),
                            $text.overflow.ellipsis(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TrackGroupVisibilityWidget(
              group: group,
              isActive: isActive,
              isExpanded: isExpanded,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.expanded,
      builder: (_, expanded, __) {
        final isExpanded = expanded.contains(group);
        return VBox(
          style: Style(
            $flex.crossAxisAlignment.start(),
            $box.color.transparent(),
            $box.border.only(top: BorderSideDto(color: ColorDto(Colors.black))),
          ),
          children: [
            SizedBox(width: trackNameWidth, child: _groupName(isExpanded)),

            if (isExpanded)
              ...group.tracks
                  .map(
                    (track) => HBox(
                      style: Style(
                        $box.border.bottom(color: Colors.black),
                        $box.padding.vertical(12),
                        $flex.crossAxisAlignment.start(),
                      ),
                      children: [
                        SizedBox(
                          width: trackNameWidth,
                          child: AnimationChannelEditorWidget(
                            group: group,
                            track: track,
                            controller: controller,
                            keyframeToggleIconBuilder:
                                keyframeToggleIconBuilder,
                          ),
                        ),
                        Expanded(
                          child: TrackKeyframesWidget(
                            controller: controller,
                            scrollController: scrollController,
                            track: track,
                            keyframeIconBuilder: keyframeIconBuilder,
                          ),
                        ),
                      ],
                    ),
                  )
                  .cast<Widget>(),
          ],
        );
      },
    );
  }
}
