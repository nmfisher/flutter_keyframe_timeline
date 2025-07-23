import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyframe_timeline_example/object/objects.dart';
import 'package:mix/mix.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';


class TrackGroupVisibilityWidget extends StatelessWidget {
  final RandomObject object;
  final bool isActive;
  final bool isExpanded;

  const TrackGroupVisibilityWidget({
    super.key,
    required this.object,
    required this.isActive,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: object.isVisible,
      builder: (_, isVisible, __) {
        return PressableBox(
          onPress: () {
            object.isVisible.value = !object.isVisible.value;
          },

            child: StyledIcon(
              isVisible ? PhosphorIcons.checkSquare() : PhosphorIcons.square(),
              style: Style($icon.size(16.0), $icon.color(Colors.red.withOpacity(isActive || isExpanded ? 1.0 : 0.5),
            ),
          ),
        ));
      },
    );
  }
}
