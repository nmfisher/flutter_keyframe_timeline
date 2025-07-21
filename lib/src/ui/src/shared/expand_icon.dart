import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mix/mix.dart';

class CustomExpandIcon extends StatelessWidget {
  final bool isExpanded;
  final bool isActive;
  final void Function(bool expand) setExpanded;

  const CustomExpandIcon({
    super.key,
    required this.isExpanded,
    required this.setExpanded,
    this.isActive = true
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (d) {
        if (d.buttons & kPrimaryMouseButton == kPrimaryMouseButton) {
          setExpanded(!isExpanded);
        }
      },
      child: StyledIcon(
        isExpanded ? Icons.expand_more : Icons.chevron_right,
        style: Style(
          $icon.color.black.withOpacity(isActive || isExpanded ? 1.0 : 0.5),
        ),
      ),
    );
  }
}
