import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/shared/mouse_hover_widget.dart';
import 'package:mix/mix.dart';

class KeyframeDisplayWidget extends StatefulWidget {
  final int pixelsPerFrame;
  final int frameNumber;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final ValueChanged<int>? onFrameNumberChanged;

  const KeyframeDisplayWidget({
    super.key,
    required this.pixelsPerFrame,
    required this.frameNumber,
    required this.isSelected,
    this.onTap,
    this.onDelete,
    this.onFrameNumberChanged,
  });

  @override
  State<KeyframeDisplayWidget> createState() => _KeyframeDisplayWidgetState();
}

class _KeyframeDisplayWidgetState extends State<KeyframeDisplayWidget> {
  Offset? dragStart;
  int initialFrame = 0;

  late final _focusNode = FocusNode();

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
      // color: darkNeonTheme.colors[$token.color.surface],
      items: [
        PopupMenuItem(
          child: Box(
            // style: MenuStyle.item,
            child: Text(
              'Delete',
              // style: TextStyle(
              //   color: darkNeonTheme.colors[$token.color.onSurface],
              // ),
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

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.delete) {
          widget.onDelete?.call();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: MouseHoverWidget(
        builder: (isHovered) => GestureDetector(
          behavior: HitTestBehavior.translucent,
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
          child: Transform.translate(
            offset: const Offset(-16, 0.0),
            child: Container(
              padding: EdgeInsets.all(4),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? Colors.amber.withOpacity(0.2)
                      : Colors.black,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      // darkNeonTheme.colors[$token
                      //     .color
                      //     .primary],
                      shape: BoxShape.circle,
                      border: Border.all(
                        // color:
                        //     isHovered || widget.isSelected
                        //         ? Colors.white
                        //         : darkNeonTheme.colors[$token
                        //             .color
                        //             .onSurfaceVariant]!,
                        width: isHovered || widget.isSelected ? 2 : 1,
                      ),
                      boxShadow: widget.isSelected
                          ? [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
