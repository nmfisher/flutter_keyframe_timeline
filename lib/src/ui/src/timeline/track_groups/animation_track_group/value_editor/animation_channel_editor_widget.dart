import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';
import 'package:flutter_keyframe_timeline/src/model/model.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/shared/numeric/numeric_control_row.dart';
import 'package:mix/mix.dart';

import 'animation_channel_editor_viewmodel.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';

class AnimationChannelEditorWidget extends StatefulWidget {
  final AnimationTrack track;
  final TimelineController controller;

  const AnimationChannelEditorWidget({
    super.key,
    required this.track,
    required this.controller,
  });

  @override
  State<AnimationChannelEditorWidget> createState() =>
      _AnimationChannelEditorWidgetState();
}

class _AnimationChannelEditorWidgetState
    extends State<AnimationChannelEditorWidget> {
  late final AnimationChannelEditorViewModel viewModel =
      AnimationChannelEditorViewModelImpl(widget.track, widget.controller);

  @override
  void dispose() {
    super.dispose();
    viewModel.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.track.labels;

    final icon = ValueListenableBuilder(
      valueListenable: viewModel.hasKeyframeAtCurrentFrame,
      builder: (_, hasKeyframeAtCurrentFrame, __) => IconButton(
        key: Key(
          "${widget.track.hashCode}_editor_has_keyframe_at_current_frame_$hasKeyframeAtCurrentFrame",
        ),
        onPressed: () {
          if (!hasKeyframeAtCurrentFrame) {
            viewModel.addKeyframeForCurrentFrame();
          } else {
            viewModel.deleteKeyframeForCurrentFrame();
          }
        },
        icon: PhosphorIcon(
          PhosphorIcons.diamond(),
          color: hasKeyframeAtCurrentFrame
              ? Colors.amber
              : Colors.pink, // $token.color.onSurfaceVariant.resolve(context),
          size: 12,
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      ),
    );

    return SizedBox(
      height: 48,
      child: ValueListenableBuilder(
        valueListenable: viewModel.valueAtCurrentFrame,
        builder: (_, ChannelValueType value, __) {
          var unwrapped = value.unwrap();
          return NumericControlRow(
            key: ObjectKey(value),
            label: "Position",
            dimensionLabels: labels,
            values: unwrapped,
            onValuesChanged: (values) => viewModel.setCurrentFrameValue(values),
            icon: icon,
            step: 0.01,
          );
        },
      ),
    );
  }
}
