import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/track_groups/track_object_widget.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/timeline_style.dart';
import 'package:mix/mix.dart';

class TrackObjectsWidget extends StatefulWidget {
  final TimelineController controller;
  final ScrollController horizontalScrollController;
  final double trackNameWidth;
  final KeyframeIconBuilder keyframeIconBuilder;
  final KeyframeToggleIconBuilder? keyframeToggleIconBuilder;
  final TrackObjectExtraWidgetBuilder? trackObjectExtraWidgetBuilder;
  final TrackObjectNameStyle? trackObjectNameStyle;
  final NumericControlStyle? numericControlStyle;
  final ChannelTextfieldWidgetBuilder? channelTextfieldWidgetBuilder;
  const TrackObjectsWidget({
    super.key,
    required this.controller,
    required this.horizontalScrollController,
    required this.trackNameWidth,
    required this.keyframeIconBuilder,
    this.keyframeToggleIconBuilder,
    this.trackObjectExtraWidgetBuilder,
    this.trackObjectNameStyle,
    this.numericControlStyle,
    this.channelTextfieldWidgetBuilder,
  });

  @override
  State<TrackObjectsWidget> createState() => _TrackObjectsWidgetState();
}

class _TrackObjectsWidgetState extends State<TrackObjectsWidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller.animatableObjects,
      builder: (_, objects, __) => VBox(
        key: ObjectKey(widget.controller.animatableObjects),
        style: Style($flex.crossAxisAlignment.start()),
        children: objects
            .asMap()
            .map(
              (idx, object) => MapEntry(
                idx,
                TrackObjectWidget(
                  key: ObjectKey(object),
                  object: object,
                  index: idx,
                  controller: widget.controller,
                  trackNameWidth: widget.trackNameWidth,
                  scrollController: widget.horizontalScrollController,
                  keyframeIconBuilder: widget.keyframeIconBuilder,
                  keyframeToggleIconBuilder: widget.keyframeToggleIconBuilder,
                  additionalWidgetBuilder: widget.trackObjectExtraWidgetBuilder,
                  trackObjectNameStyle: widget.trackObjectNameStyle,
                  numericControlStyle: widget.numericControlStyle,
                  channelTextfieldWidgetBuilder: widget.channelTextfieldWidgetBuilder,
                ),
              ),
            )
            .values
            .cast<Widget>()
            .toList(),
      ),
    );
  }
}
