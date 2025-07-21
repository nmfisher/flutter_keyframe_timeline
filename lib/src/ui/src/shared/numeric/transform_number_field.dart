import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mix/mix.dart';
import 'draggable_number_field.dart';

class TransformNumberField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final Function(double) onChanged;
  final Function(DragStartDetails) onDragStart;
  final Function(DragUpdateDetails) onDragUpdate;
  final Function(DragEndDetails) onDragEnd;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final double min;
  final double max;

  const TransformNumberField({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    this.onSubmitted,
    this.onEditingComplete,
    this.min = -100.0,
    this.max = 100.0,
  });

  @override
  State<TransformNumberField> createState() => _TransformNumberFieldState();
}

class _TransformNumberFieldState extends State<TransformNumberField>
    with SingleTickerProviderStateMixin {
  bool isEditing = false;
  bool isHovered = false;
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _textFieldKey = GlobalKey();
  late AnimationController _controller; 
  late Animation<double> _animation; 

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
    duration: const Duration(milliseconds: 167),
    vsync: this,
  );
  _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
  }

  void _handleFocusChange() {
    setState(() => isEditing = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    // var textStyle = darkNeonTheme.textStyles[$token.textStyle.label];
    final style = TextStyle(
      // color: $token.color.onSurfaceVariant.resolve(context),
      fontSize: 11,
      // fontFamily: textStyle?.fontFamily,
    );
    // final decoration = TransformControlsStyle.getTextFieldDecoration(
    //   widget.label,
    // );

    return Box(
      style: Style($box.width(52)),
      child: DraggableNumberField(
        onDragStart: widget.onDragStart,
        onDragUpdate: widget.onDragUpdate,
        onDragEnd: widget.onDragEnd,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            TextField(
              key: _textFieldKey,
              controller: widget.controller,
              focusNode: _focusNode,
              style: style,
              // decoration: decoration,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]')),
              ],
              onChanged: (text) {
                final newValue = double.tryParse(text);
                if (newValue != null) {
                  final clampedValue = newValue.clamp(widget.min, widget.max);
                  widget.onChanged(clampedValue);
                }
              },
              onSubmitted: widget.onSubmitted,
              onEditingComplete: widget.onEditingComplete,
            ),
            Positioned(
              left: 0,
              top: 0,
              width: 100,

              child: MouseRegion(
                onEnter: (_) {
                  setState(() => isHovered = true);
                  if (mounted) {
                    _controller.forward();
                  }
                },
                onExit: (_) {
                  setState(() => isHovered = false);
                  if (mounted) {
                    _controller.reverse();
                  }
                },
                child: GestureDetector(
                  onTapDown: (_) => _focusNode.requestFocus(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.transparent),
                  ),
                ),
              ),
            ),
            // if (decoration.label != null)
            //   Padding(
            //       padding: const EdgeInsets.symmetric(horizontal: 4),
            //       child: DefaultTextStyle(
            //         style: style.copyWith(
            //           color:
            //               isHovered
            //                   ? Theme.of(context).colorScheme.primary
            //                   : style.color?.withOpacity(0.7),
            //           fontSize: 12,
            //         ),
            //         child: decoration.label!,
            //       ),
                
            //   ),
          ],
        ),
      ),
    );
  }
}
