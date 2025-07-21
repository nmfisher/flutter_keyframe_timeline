import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';
import 'package:mix/mix.dart';

class FrameDragHandle extends StatefulWidget {
  final ScrollController scrollController;

  final TimelineController controller;
  final double playheadWidth;
  final double playheadHeight;

  const FrameDragHandle({
    super.key,
    required this.scrollController,
    required this.controller,
    this.playheadWidth = 75,
    this.playheadHeight = 75,
  });

  @override
  State<StatefulWidget> createState() {
    return _FrameDragHandleState();
  }
}

class _FrameDragHandleState extends State<FrameDragHandle> {
  bool isDragging = false;

  void _handleMouseEnter(PointerEnterEvent event) {}

  void _handleMouseExit(PointerExitEvent event) {}

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScrollControllerChange);
  }

  @override
  void dispose() {
    super.dispose();
    widget.scrollController.removeListener(_onScrollControllerChange);
  }

  void _onScrollControllerChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.scrollController.hasClients) {
      return SizedBox.shrink();
    }
    return ValueListenableBuilder(
      valueListenable: widget.controller.pixelsPerFrame,
      builder: (_, pixelsPerFrame, __) => ValueListenableBuilder(
        valueListenable: widget.controller.currentFrame,
        builder: (_, frameNumber, __) => Transform.translate(
          offset: Offset(
            (frameNumber.toDouble() * pixelsPerFrame) -
                (widget.playheadWidth / 2) -
                widget.scrollController.offset,

            0,
          ),
          child: SizedBox(
            width: widget.playheadWidth,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                MouseRegion(
                  onEnter: _handleMouseEnter,
                  onExit: _handleMouseExit,
                  cursor: isDragging
                      ? SystemMouseCursors.grabbing
                      : SystemMouseCursors.grab,
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerMove: (event) {
                      if (!widget.scrollController.hasClients) {
                        return;
                      }
                      final parentBox = context.findRenderObject() as RenderBox;
                      final localPosition = parentBox.globalToLocal(
                        event.position,
                      );

                      var currentFrame =
                          ((widget.scrollController.offset + localPosition.dx) /
                                  widget.controller.pixelsPerFrame.value)
                              .floor();
                      if (currentFrame >= 0) {
                        widget.controller.setCurrentFrame(currentFrame);
                      }
                    },
                    child: Box(
                      style: Style(
                        $box.width(widget.playheadWidth),
                        $box.height(widget.playheadHeight),
                        // $box.padding.vertical(12.0),
                        $box.alignment.center(),
                        $box.color(Colors.purple),
                        $box.borderRadius(4),
                        $with.cursor.grab(),
                        $on.press($with.cursor.grabbing()),
                      ),
                      child: StyledText(
                        frameNumber.toString(),
                        style: Style(
                          $text.textAlign.center(),
                          $text.style.fontSize(12),
                          $text.style.color(
                            Colors.white,
                            // $box.color.white
                            // $token.color.onSurfaceVariant
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Box(style: Style($box.width(2), $box.color.black())),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
