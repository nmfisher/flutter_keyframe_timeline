import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';
import 'package:mix/mix.dart';
import 'animation_track_value_editor_viewmodel.dart';

class AnimationTrackValueEditorWidget extends StatefulWidget {
  final AnimatableObject object;
  final AnimationTrack track;
  final TimelineController controller;
  final KeyframeToggleIconBuilder? keyframeToggleIconBuilder;
  final ChannelValueEditorStyle? channelValueEditorStyle;
  final ChannelValueTextFieldWidgetBuilder? channelValueEditorContainerBuilder;

  const AnimationTrackValueEditorWidget({
    super.key,
    required this.object,
    required this.track,
    required this.controller,
    this.keyframeToggleIconBuilder,
    this.channelValueEditorStyle,
    this.channelValueEditorContainerBuilder,
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

  // Channel value editor state
  late final List<TextEditingController> controllers;
  late List<double> currentValues;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(
      widget.track.labels.length,
      (_) => TextEditingController(),
    );
    currentValues = List.generate(widget.track.labels.length, (_) => 0.0);
  }

  @override
  void dispose() {
    super.dispose();
    viewModel.dispose();
    for (var controller in controllers) {
      controller.dispose();
    }
  }

  void _updateControllers(List<num> values) {
    for (var i = 0; i < controllers.length; i++) {
      final newText = values[i].toStringAsFixed(2);
      if (controllers[i].text != newText) {
        controllers[i].text = newText;
      }
    }
  }

  void _onChannelChanged(int channelIndex, double newValue) {
    final newValues = List<double>.from(currentValues);
    newValues[channelIndex] = newValue;
    currentValues = newValues;
    viewModel.setCurrentFrameValue(newValues);
  }

  Widget _buildNumberField(
    String label,
    TextEditingController controller,
    int index,
  ) {
    final textField = TextField(
      controller: controller,
      style: TextStyle(
        color: widget.channelValueEditorStyle?.textColor ?? Colors.black,
        fontSize: widget.channelValueEditorStyle?.fontSize ?? 11,
      ),
      decoration:
          widget.channelValueEditorStyle?.inputDecoration ??
          InputDecoration(
            border: widget.channelValueEditorStyle?.borderColor != null
                ? OutlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.channelValueEditorStyle!.borderColor!,
                    ),
                  )
                : null,
            enabledBorder:
                widget.channelValueEditorStyle?.enabledBorderColor != null
                ? OutlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          widget.channelValueEditorStyle!.enabledBorderColor!,
                    ),
                  )
                : null,
            focusedBorder:
                widget.channelValueEditorStyle?.focusedBorderColor != null
                ? OutlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          widget.channelValueEditorStyle!.focusedBorderColor!,
                    ),
                  )
                : null,
            errorBorder:
                widget.channelValueEditorStyle?.errorBorderColor != null
                ? OutlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.channelValueEditorStyle!.errorBorderColor!,
                    ),
                  )
                : null,
            fillColor: widget.channelValueEditorStyle?.backgroundColor,
            filled: widget.channelValueEditorStyle?.backgroundColor != null,
            isDense: true,
            contentPadding: const EdgeInsets.all(8),
          ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onSubmitted: (text) {
        final value = double.parse(text);
        _onChannelChanged(index, value);
      },
      onChanged: (text) {
        
      },
    );

    return SizedBox(
      width: widget.channelValueEditorStyle?.width ?? 52,
      child:
          widget.channelValueEditorContainerBuilder?.call(
            context,
            textField,
            controller,
            label,
            index,
          ) ??
          textField,
    );
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

          // Update current values and controllers
          if (!listEquals(currentValues, unwrapped)) {
            currentValues = List.from(unwrapped);
            _updateControllers(unwrapped);
          }

          return HBox(
            children: [
              icon,
              ...List.generate(
                labels.length,
                (index) =>
                    _buildNumberField(labels[index], controllers[index], index),
              ),
            ],
          );
        },
      ),
    );
  }
}
