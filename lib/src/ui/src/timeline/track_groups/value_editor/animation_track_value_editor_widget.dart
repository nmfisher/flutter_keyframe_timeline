import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';
import 'package:mix/mix.dart';
import 'animation_track_value_editor_viewmodel.dart';

class TrackValueEditorWidget extends StatefulWidget {
  final TimelineObject object;
  final Track track;
  final TimelineController controller;
  final KeyframeToggleIconBuilder keyframeToggleIconBuilder;
  final ChannelValueEditorStyle channelValueEditorStyle;
  final ChannelValueTextFieldWidgetBuilder? channelValueEditorContainerBuilder;

  const TrackValueEditorWidget({
    super.key,
    required this.object,
    required this.track,
    required this.controller,
    required this.keyframeToggleIconBuilder,
    this.channelValueEditorStyle = const ChannelValueEditorStyle(),
    this.channelValueEditorContainerBuilder,
  });

  @override
  State<TrackValueEditorWidget> createState() =>
      _TrackValueEditorWidgetState();
}

class _TrackValueEditorWidgetState
    extends State<TrackValueEditorWidget> {
  late final TrackValueEditorViewModel viewModel =
      TrackValueEditorViewModelImpl(
    widget.object,
    widget.track,
    widget.controller,
  );

  // Channel value editor state
  late final List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(
      widget.track.labels.length,
      (_) => TextEditingController(),
    );
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
    viewModel.setActualValue(channelIndex, newValue);
  }

  Widget _buildNumberField(
    String label,
    TextEditingController controller,
    int index,
  ) {
    final textField = TextField(
      controller: controller,
      style: TextStyle(
        color: widget.channelValueEditorStyle.textFieldFontColor,
        fontSize: widget.channelValueEditorStyle.textFieldFontSize,
      ),
      decoration: widget.channelValueEditorStyle.inputDecoration ??
          InputDecoration(
            border: widget.channelValueEditorStyle.borderColor != null
                ? OutlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.channelValueEditorStyle.borderColor!,
                    ),
                  )
                : null,
            enabledBorder: widget.channelValueEditorStyle.enabledBorderColor !=
                    null
                ? OutlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.channelValueEditorStyle.enabledBorderColor!,
                    ),
                  )
                : null,
            focusedBorder: widget.channelValueEditorStyle.focusedBorderColor !=
                    null
                ? OutlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.channelValueEditorStyle.focusedBorderColor!,
                    ),
                  )
                : null,
            errorBorder: widget.channelValueEditorStyle.errorBorderColor != null
                ? OutlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.channelValueEditorStyle.errorBorderColor!,
                    ),
                  )
                : null,
            fillColor: widget.channelValueEditorStyle.backgroundColor,
            filled: widget.channelValueEditorStyle.backgroundColor != null,
            isDense: true,
            contentPadding: const EdgeInsets.all(8),
          ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onSubmitted: (text) {
        final value = double.parse(text);
        _onChannelChanged(index, value);
      },
      onChanged: (text) {},
    );

    return SizedBox(
      width: widget.channelValueEditorStyle.width ?? 52,
      child: widget.channelValueEditorContainerBuilder?.call(
            context,
            textField,
            controller,
            label,
            index,
          ) ??
          textField,
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

        return widget.keyframeToggleIconBuilder(
          context,
          hasKeyframeAtCurrentFrame,
          onPressed,
        );
      },
    );

    return VBox(
      style: Style($flex.crossAxisAlignment.start()),
      children: [
        widget.channelValueEditorStyle.labelBuilder(widget.track.label),
        ValueListenableBuilder(
          valueListenable: viewModel.values,
          builder: (_, List<num> values, __) {
            _updateControllers(values);

            return HBox(
              children: [
                icon,
                ...List.generate(
                  labels.length,
                  (index) => _buildNumberField(
                      labels[index], controllers[index], index),
                ),
              ],
            );
          },
        )
      ],
    );
  }
}
