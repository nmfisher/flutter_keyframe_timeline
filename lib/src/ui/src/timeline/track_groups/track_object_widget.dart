import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/shared/expand_icon.dart';

import 'package:flutter_keyframe_timeline/src/ui/src/timeline/track_groups/track_keyframes_widget.dart';
import 'package:flutter_keyframe_timeline/src/wrapper/wrapper_factory.dart' as wrapper;
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/track_groups/value_editor/animation_track_value_editor_widget.dart';
import 'package:mix/mix.dart';

// Import for clip widget
import 'clip_widget.dart';

class TrackObjectWidget extends StatelessWidget {
  final TimelineController controller;
  final ScrollController scrollController;
  final FlutterTimelineObject object;

  final int index;
  final double trackNameWidth;
  final KeyframeIconBuilder keyframeIconBuilder;
  final KeyframeToggleIconBuilder keyframeToggleIconBuilder;
  final TrackObjectExtraWidgetBuilder? additionalWidgetBuilder;
  final TrackObjectNameStyle? trackObjectNameStyle;
  final ChannelValueEditorStyle? channelValueEditorStyle;
  final ChannelValueTextFieldWidgetBuilder? channelValueEditorContainerBuilder;
  final KeyframeConnectionStyle keyframeConnectionStyle;

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
    required this.keyframeConnectionStyle,
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
                        valueListenable: object.displayNameListenable,
                        builder: (_, displayName, __) => StyledText(
                          displayName,
                          style: Style(
                            $text.color((trackObjectNameStyle?.textColor ??
                                    Colors.black)
                                .withValues(alpha: isActive ? 1.0 : 0.5)),
                            $text.overflow.ellipsis(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (additionalWidgetBuilder != null)
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
            $box.border.only(
                top: BorderSideDto(
                    color: ColorDto(
                        trackObjectNameStyle?.borderColor ?? Colors.black))),
          ),
          children: [
            SizedBox(
                width: trackNameWidth, child: _objectName(isExpanded, context)),

            if (isExpanded)
              ...object
                  .getTracks<KeyframeTrack>()
                  .cast<FlutterKeyframeTrack>()
                  .map(
                    (track) => HBox(
                      style: Style(
                        $box.border.bottom(
                            color: trackObjectNameStyle?.borderColor ??
                                Colors.black),
                        $box.padding.vertical(12),
                        $flex.crossAxisAlignment.start(),
                      ),
                      children: [
                        SizedBox(
                          width: trackNameWidth,
                          child: TrackValueEditorWidget(
                            object: object,
                            track: track,
                            controller: controller,
                            keyframeToggleIconBuilder:
                                keyframeToggleIconBuilder,
                            channelValueEditorStyle: channelValueEditorStyle ??
                                const ChannelValueEditorStyle(),
                            channelValueEditorContainerBuilder:
                                channelValueEditorContainerBuilder,
                          ),
                        ),
                        Expanded(
                          child: TrackKeyframesWidget(
                            controller: controller,
                            scrollController: scrollController,
                            track: wrapper.WrapperFactory.wrapBaseTrack(track),
                            keyframeIconBuilder: keyframeIconBuilder,
                            connectionStyle: keyframeConnectionStyle,
                          ),
                        ),
                      ],
                    ),
                  )
                  .cast<Widget>(),

            // Add VideoTrack rendering
            ...object
                .getTracks<VideoTrack>()
                .cast<FlutterVideoTrack>()
                .map(
                  (videoTrack) => HBox(
                    style: Style(
                      $box.border.bottom(
                          color: trackObjectNameStyle?.borderColor ??
                              Colors.black),
                      $box.padding.vertical(8),
                      $flex.crossAxisAlignment.start(),
                    ),
                    children: [
                      SizedBox(
                        width: trackNameWidth,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 24.0),
                          child: StyledText(
                            videoTrack.label,
                            style: Style(
                              $text.fontSize(12),
                              $text.color(Colors.black.withValues(alpha: 0.7)),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipWidget(
                          videoTrack: videoTrack,
                          controller: controller,
                          scrollController: scrollController,
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
