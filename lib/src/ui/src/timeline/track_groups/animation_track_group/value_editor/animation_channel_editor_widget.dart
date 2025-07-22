import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/shared/numeric/numeric_control_row.dart';
import 'animation_channel_editor_viewmodel.dart';

class AnimationChannelEditorWidget extends StatefulWidget {
  final AnimationTrackGroup group;
  final AnimationTrack track;
  final TimelineController controller;
  final KeyframeToggleIconBuilder? keyframeToggleIconBuilder;

  const AnimationChannelEditorWidget({
    super.key,
    required this.group,
    required this.track,
    required this.controller,
    this.keyframeToggleIconBuilder,
  });

  @override
  State<AnimationChannelEditorWidget> createState() =>
      _AnimationChannelEditorWidgetState();
}

class _AnimationChannelEditorWidgetState
    extends State<AnimationChannelEditorWidget> {
  late final AnimationChannelEditorViewModel viewModel =
      AnimationChannelEditorViewModelImpl(
        widget.group,
        widget.track,
        widget.controller,
      );

  @override
  void dispose() {
    super.dispose();
    viewModel.dispose();
  }

  static Widget _defaultToggleIconBuilder(
    BuildContext context,
    bool hasKeyframeAtCurrentFrame,
    VoidCallback onPressed,
  ) {
    return IconButton(
      onPressed: onPressed,
      icon: Transform.rotate(
        angle: 0.785398, // 45 degrees in radians (pi/4) for diamond shape
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: hasKeyframeAtCurrentFrame
                ? Colors.blue
                : Colors.grey.withValues(alpha: 0.2),
            border: Border.all(
              color: hasKeyframeAtCurrentFrame
                  ? Colors.black
                  : Colors.grey.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.track.labels;

    final icon = ValueListenableBuilder(
      valueListenable: viewModel.hasKeyframeAtCurrentFrame,
      builder: (_, hasKeyframeAtCurrentFrame, __) {
        void onPressed() {
          if (!hasKeyframeAtCurrentFrame) {
            viewModel.addKeyframeForCurrentFrame();
          } else {
            viewModel.deleteKeyframeForCurrentFrame();
          }
        }

        if (widget.keyframeToggleIconBuilder != null) {
          return widget.keyframeToggleIconBuilder!(
            context,
            hasKeyframeAtCurrentFrame,
            onPressed,
          );
        }

        return _defaultToggleIconBuilder(
          context,
          hasKeyframeAtCurrentFrame,
          onPressed,
        );
      },
    );

    return SizedBox(
      height: 48,
      child: ValueListenableBuilder(
        valueListenable: widget.controller.currentFrame,
        builder: (_, int currentFrame, __) {
          var value = viewModel.getValue(currentFrame);
          var unwrapped = value.unwrap();
          return NumericControlRow(
            label: widget.track.label,
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
