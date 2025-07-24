import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/shared/channel_value_editor_widget.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/timeline_style.dart';
import 'animation_track_value_editor_viewmodel.dart';

class AnimationTrackValueEditorWidget extends StatefulWidget {
  final AnimatableObject object;
  final AnimationTrack track;
  final TimelineController controller;
  final KeyframeToggleIconBuilder? keyframeToggleIconBuilder;
  final NumericControlStyle? numericControlStyle;
  final ChannelTextfieldWidgetBuilder? channelTextfieldWidgetBuilder;

  const AnimationTrackValueEditorWidget({
    super.key,
    required this.object,
    required this.track,
    required this.controller,
    this.keyframeToggleIconBuilder,
    this.numericControlStyle,
    this.channelTextfieldWidgetBuilder,
  });

  @override
  State<AnimationTrackValueEditorWidget> createState() =>
      _AnimationTrackValueEditorWidgetState();
}

class _AnimationTrackValueEditorWidgetState
    extends State<AnimationTrackValueEditorWidget> {
  late final AnimationTrackValueEditorViewModel viewModel =
      AnimationTrackValueEditorViewModelImpl(
        widget.object,
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
          return ChannelValueEditorWidget(
            label: widget.track.label,
            dimensionLabels: labels,
            values: unwrapped,
            onValuesChanged: (values) => viewModel.setCurrentFrameValue(values),
            icon: icon,
            step: 0.01,
            numericControlStyle: widget.numericControlStyle,
            channelTextfieldWidgetBuilder: widget.channelTextfieldWidgetBuilder,
          );
        },
      ),
    );
  }
}
