import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';
import 'package:mix/mix.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TrackGroupVisibilityWidget extends StatelessWidget {
  final AnimationTrackGroup group;
  final bool isActive;
  final bool isExpanded;

  const TrackGroupVisibilityWidget({super.key, required this.group, required this.isActive, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: group.isVisible,
      builder: (_, isVisible, __) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            group.setVisible(!isVisible);
          },
          child: Box(
            child: Icon(
              isVisible ? PhosphorIcons.checkSquare() : PhosphorIcons.square(),
              size: 16,
              color: Colors.red.withOpacity(
                isActive || isExpanded ? 1.0 : 0.5,
              ),
            ),
          ),
        );
      },
    );
  }
}
