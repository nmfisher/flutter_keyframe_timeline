import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/shared/numeric/transform_number_field.dart';

import 'package:mix/mix.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class NumericControlRow extends StatefulWidget {
  final String label;
  final bool showLabel;
  final List<String> dimensionLabels;

  final double step;
  final double max;
  final double min;
  final List<num> values;

  final void Function(List<double>) onValuesChanged;

  final Widget icon;

  const NumericControlRow({
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
  });

  @override
  State<NumericControlRow> createState() => _NumericControlRowState();
}

class _NumericControlRowState extends State<NumericControlRow> {
  late final List<TextEditingController> controllers;
  bool isUpdatingControllers = false;
  double? dragStartX;
  int? draggingIndex;
  List<double> lastValues = [];
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
    lastValues = List.from(widget.values);
    _updateControllers(widget.values);
  }

  @override
  void didUpdateWidget(covariant NumericControlRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.values, widget.values)) {
      currentValues = List.from(widget.values);
      lastValues = List.from(widget.values);
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

  void _handleDragStart(int index, DragStartDetails details) {
    dragStartX = details.globalPosition.dx;
    draggingIndex = index;
    lastValues = List.from(currentValues);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (dragStartX != null && draggingIndex != null) {
      final delta = details.globalPosition.dx - dragStartX!;
      final steps = (delta / 5).round();
      final currentValue = lastValues[draggingIndex!];
      final newValue = (currentValue + steps * widget.step).clamp(
        widget.min,
        widget.max,
      );

      if (newValue != currentValues[draggingIndex!]) {
        controllers[draggingIndex!].text = newValue.toStringAsFixed(2);
        _onDimensionChanged(draggingIndex!, newValue);
      }
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    dragStartX = null;
    draggingIndex = null;
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
    Function(double) onChanged,
    int index,
  ) {
    return TransformNumberField(
      label: label,
      controller: controller,
      onChanged: onChanged,
      onDragStart: (details) => _handleDragStart(index, details),
      onDragUpdate: (details) => _handleDragUpdate(details),
      onDragEnd: _handleDragEnd,
      onSubmitted: (_) => setState(() => editingIndex = null),
      onEditingComplete: () => setState(() => editingIndex = null),
      min: widget.min,
      max: widget.max,
    );
  }

  @override
  Widget build(BuildContext context) {
    return 
        HBox(
          // style: Style.combine([TransformControlsStyle.transformRow, Style($box.height(TimelineStyle.lineHeight), $flex.gap(4.0)),]),
          
          children: [
            widget.icon,
            ...List.generate(
              widget.dimensionLabels.length,
              (index) => _buildNumberField(
                widget.dimensionLabels[index],
                controllers[index],
                (value) => _onDimensionChanged(index, value),
                index,
              ),
            ),
          ],
        
    );
  }
}
