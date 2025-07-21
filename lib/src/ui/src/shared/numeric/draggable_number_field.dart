import 'package:flutter/material.dart';

class DraggableNumberField extends StatefulWidget {
  final Widget child;
  final Function(DragStartDetails) onDragStart;
  final Function(DragUpdateDetails) onDragUpdate;
  final Function(DragEndDetails) onDragEnd;

  const DraggableNumberField({super.key, 
    required this.child,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  State<DraggableNumberField> createState() => DraggableNumberFieldState();
}

class DraggableNumberFieldState extends State<DraggableNumberField> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      cursor: isHovering ? SystemMouseCursors.resizeLeftRight : SystemMouseCursors.text,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: widget.onDragStart,
        onHorizontalDragUpdate: widget.onDragUpdate,
        onHorizontalDragEnd: widget.onDragEnd,
        child: widget.child,
      ),
    );
  }
}