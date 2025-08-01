import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyframe_timeline_example/object/objects.dart';
import 'package:mix/mix.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TrackObjectVisibilityWidget extends StatelessWidget {
  final RandomObject object;
  final bool isActive;
  final bool isExpanded;
  final VoidCallback? onRemove;

  const TrackObjectVisibilityWidget({
    super.key,
    required this.object,
    required this.isActive,
    required this.isExpanded,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: object.isVisible,
      builder: (_, isVisible, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PressableBox(
              onPress: () {
                object.isVisible.value = !object.isVisible.value;
              },
              child: StyledIcon(
                isVisible ? PhosphorIcons.checkSquare() : PhosphorIcons.square(),
                style: Style(
                  $icon.size(16.0), 
                  $icon.color(Colors.red.withOpacity(isActive || isExpanded ? 1.0 : 0.5)),
                ),
              ),
            ),
            if (onRemove != null) ...[
              const SizedBox(width: 8),
              PressableBox(
                onPress: onRemove,
                child: StyledIcon(
                  PhosphorIcons.trash(),
                  style: Style(
                    $icon.size(16.0),
                    $icon.color(Colors.red.withOpacity(isActive || isExpanded ? 1.0 : 0.5)),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
