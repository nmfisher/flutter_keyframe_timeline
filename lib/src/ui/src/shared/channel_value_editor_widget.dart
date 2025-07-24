import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/timeline_style.dart';

import 'package:mix/mix.dart';

class ChannelValueEditorWidget extends StatefulWidget {
  final String label;
  final bool showLabel;
  final List<String> dimensionLabels;

  final double step;
  final double max;
  final double min;
  final List<num> values;

  final void Function(List<double>) onValuesChanged;

  final Widget icon;
  final NumericControlStyle? numericControlStyle;
  final ChannelTextfieldWidgetBuilder? channelTextfieldWidgetBuilder;

  const ChannelValueEditorWidget({
    super.key,
    required this.label,
    required this.dimensionLabels,
    required this.values,
    required this.onValuesChanged,
    required this.icon,

    this.step = 0.5,
    this.max = 100.0,
    this.min = -100.0,
    this.showLabel = false,
    this.numericControlStyle,
    this.channelTextfieldWidgetBuilder,
  });

  @override
  State<ChannelValueEditorWidget> createState() => _ChannelValueEditorWidgetState();
}

class _ChannelValueEditorWidgetState extends State<ChannelValueEditorWidget> {
  late final List<TextEditingController> controllers;
  bool isUpdatingControllers = false;
  int? editingIndex;
  late List<double> currentValues;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(
      widget.dimensionLabels.length,
      (_) => TextEditingController(),
    );
    currentValues = List.from(widget.values);
    _updateControllers(widget.values);
  }

  @override
  void didUpdateWidget(covariant ChannelValueEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.values, widget.values)) {
      currentValues = List.from(widget.values);
      _updateControllers(widget.values);
    }
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateControllers(List<num> values) {
    isUpdatingControllers = true;
    for (var i = 0; i < controllers.length; i++) {
      final newText = values[i].toStringAsFixed(2);
      if (controllers[i].text != newText) {
        controllers[i].text = newText;
      }
    }
    isUpdatingControllers = false;
  }


  void _onDimensionChanged(int dimensionIndex, double newValue) {
    if (isUpdatingControllers) return;
    final newValues = List<double>.from(currentValues);
    newValues[dimensionIndex] = newValue;
    currentValues = newValues;

    _updateControllers(newValues);
    widget.onValuesChanged(newValues);
  }

  Widget _buildNumberField(
    String label,
    TextEditingController controller,
    int index,
  ) {
    final textField = TextField(
      controller: controller,
      style: TextStyle(
        color: widget.numericControlStyle?.textColor ?? Colors.black,
        fontSize: widget.numericControlStyle?.fontSize ?? 11,
      ),
      decoration: widget.numericControlStyle?.inputDecoration ?? 
        InputDecoration(
          border: widget.numericControlStyle?.borderColor != null
              ? OutlineInputBorder(
                  borderSide: BorderSide(color: widget.numericControlStyle!.borderColor!),
                )
              : null,
          fillColor: widget.numericControlStyle?.backgroundColor,
          filled: widget.numericControlStyle?.backgroundColor != null,
          isDense: true,
          contentPadding: const EdgeInsets.all(8),
        ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onSubmitted: (text) {
        final value = double.tryParse(text);
        if (value != null) {
          final clampedValue = value.clamp(widget.min, widget.max);
          _onDimensionChanged(index, clampedValue);
          setState(() => editingIndex = null);
        }
      },
      onEditingComplete: () => setState(() => editingIndex = null),
      onChanged: (text) {
        final value = double.tryParse(text);
        if (value != null) {
          final clampedValue = value.clamp(widget.min, widget.max);
          _onDimensionChanged(index, clampedValue);
        }
      },
    );

    if (widget.channelTextfieldWidgetBuilder != null) {
      return widget.channelTextfieldWidgetBuilder!(
        context,
        textField,
        label,
        index,
      );
    }

    return SizedBox(
      width: 52,
      child: textField,
    );
  }

  @override
  Widget build(BuildContext context) {
    return HBox(
      children: [
        widget.icon,
        ...List.generate(
          widget.dimensionLabels.length,
          (index) => _buildNumberField(
            widget.dimensionLabels[index],
            controllers[index],
            index,
          ),
        ),
      ],
    );
  }
}
