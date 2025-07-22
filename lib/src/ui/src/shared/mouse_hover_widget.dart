import 'package:flutter/material.dart';

class MouseHoverWidget extends StatefulWidget {
  final Widget Function(bool isHovered) builder;

  const MouseHoverWidget({super.key, required this.builder});

  @override
  State<StatefulWidget> createState() {
    return _MouseHoverWidgetState();
  }
}

class _MouseHoverWidgetState extends State<MouseHoverWidget> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      opaque: false,
      hitTestBehavior: HitTestBehavior.opaque,
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: widget.builder(isHovered),
    );
  }
}
