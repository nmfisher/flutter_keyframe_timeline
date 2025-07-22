import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/shared/mouse_hover_widget.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/timeline_style.dart';
import 'package:mix/mix.dart';

class KeyframeDisplayWidget extends StatefulWidget {
  final int pixelsPerFrame;
  final int frameNumber;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final ValueChanged<int> onFrameNumberChanged;
  final KeyframeIconBuilder keyframeIconBuilder;

  const KeyframeDisplayWidget({
    super.key,
    required this.pixelsPerFrame,
    required this.frameNumber,
    required this.isSelected,
    required this.keyframeIconBuilder,
    this.onTap,
    this.onDelete,
    required this.onFrameNumberChanged,
  });

  @override
  State<KeyframeDisplayWidget> createState() => _KeyframeDisplayWidgetState();
}

class _KeyframeDisplayWidgetState extends State<KeyframeDisplayWidget> {
  Offset? dragStart;
  int initialFrame = 0;

  @override
  void didUpdateWidget(KeyframeDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _showContextMenu(BuildContext context, Offset offset) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(offset, offset),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          child: Box(
            child: Text(
              'Delete',
            ),
          ),
          onTap: () {
            widget.onDelete?.call();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (details) {
          dragStart = details.localPosition;
          initialFrame = widget.frameNumber;
        },
        onTap: () {

          widget.onTap?.call();
        },
        onSecondaryTapDown: (details) {
          if (widget.isSelected) {
            _showContextMenu(context, details.globalPosition);
          }
        },
        onPanUpdate: (details) {
          if (dragStart != null) {
            final dragDelta = details.localPosition.dx - dragStart!.dx;
            final frameDelta = (dragDelta / widget.pixelsPerFrame).round();
            final newFrame = initialFrame + frameDelta;
            final clampedFrame = newFrame.clamp(0, double.infinity).toInt();
            widget.onFrameNumberChanged?.call(clampedFrame);
          }
        },
        onPanEnd: (_) {
          dragStart = null;
        },
        child: MouseHoverWidget(
          builder: (isHovered) {
            return AbsorbPointer(child:widget.keyframeIconBuilder(
              context,
              widget.isSelected,
              isHovered,
              widget.frameNumber,
            ));
          },
        ),
      
    );
  }
}
