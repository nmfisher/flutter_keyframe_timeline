import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/src/model/model.dart';
import 'package:flutter_keyframe_timeline/src/model/src/animatable_object.dart';
import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/shared/expand_icon.dart';

import 'package:flutter_keyframe_timeline/src/ui/src/timeline/timeline_style.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/track_groups/track_keyframes_widget.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/track_groups/value_editor/animation_track_value_editor_widget.dart';
import 'package:mix/mix.dart';

class TrackObjectWidget extends StatelessWidget {
  final TimelineController controller;
  final ScrollController scrollController;
  final AnimatableObject object;

  final int index;
  final double trackNameWidth;
  final KeyframeIconBuilder keyframeIconBuilder;
  final KeyframeToggleIconBuilder keyframeToggleIconBuilder;
  final TrackObjectExtraWidgetBuilder? additionalWidgetBuilder;
  final TrackObjectNameStyle? trackObjectNameStyle;
  final ChannelValueEditorStyle? channelValueEditorStyle;
  final ChannelValueTextFieldWidgetBuilder? channelValueEditorContainerBuilder;

  const TrackObjectWidget({
    super.key,
    required this.object,
    required this.controller,
    required this.scrollController,
    required this.index,
    required this.trackNameWidth,
    required this.keyframeIconBuilder,
    this.additionalWidgetBuilder,
    required this.keyframeToggleIconBuilder,
    this.trackObjectNameStyle,
    this.channelValueEditorStyle,
    this.channelValueEditorContainerBuilder,
  });

  Widget _objectName(bool isExpanded, BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.active,
      builder: (_, active, __) {
        final isActive = active.contains(object);
        return HBox(
          children: [
            Expanded(
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (details) {
                  if (details.buttons & kPrimaryMouseButton ==
                      kPrimaryMouseButton) {
                    controller.setActive(object, true);
                  }
                },
                child: HBox(
                  children: [
                    CustomExpandIcon(
                      isExpanded: isExpanded,
                      isActive: isActive,
                      setExpanded: (expanded) {
                        controller.setExpanded(object, expanded);
                      },
                      color: trackObjectNameStyle?.iconColor,
                    ),
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: object.displayName,
                        builder: (_, displayName, __) => StyledText(
                          displayName,
                          style: Style(
                            $text.color((trackObjectNameStyle?.textColor ?? Colors.black).withOpacity(isActive ? 1.0 : 0.5)),
                            $text.overflow.ellipsis(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if(additionalWidgetBuilder != null)
            additionalWidgetBuilder!(context, object, isActive, isExpanded)
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
        final isExpanded = expanded.contains(object);
        return VBox(
          style: Style(
            $flex.crossAxisAlignment.start(),
            $box.color.transparent(),
            $box.border.only(top: BorderSideDto(color: ColorDto(trackObjectNameStyle?.borderColor ?? Colors.black))),
          ),
          children: [
            SizedBox(width: trackNameWidth, child: _objectName(isExpanded, context)),

            if (isExpanded)
              ...object.tracks
                  .map(
                    (track) => HBox(
                      style: Style(
                        $box.border.bottom(color: trackObjectNameStyle?.borderColor ?? Colors.black),
                        $box.padding.vertical(12),
                        $flex.crossAxisAlignment.start(),
                      ),
                      children: [
                        SizedBox(
                          width: trackNameWidth,
                          child: AnimationTrackValueEditorWidget(
                            object: object,
                            track: track,
                            controller: controller,
                            keyframeToggleIconBuilder:
                                keyframeToggleIconBuilder,
                            channelValueEditorStyle: channelValueEditorStyle ?? const ChannelValueEditorStyle(),
                            channelValueEditorContainerBuilder: channelValueEditorContainerBuilder,
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
