import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/timeline_style.dart';
import 'package:mix/mix.dart';


class FrameDragHandle extends StatefulWidget {
  final ScrollController scrollController;
  final TimelineController controller;
  final FrameDragHandleStyle? style;

  const FrameDragHandle({
    super.key,
    required this.scrollController,
    required this.controller,
    this.style,
  });

  @override
  State<StatefulWidget> createState() {
    return _FrameDragHandleState();
  }
}

class _FrameDragHandleState extends State<FrameDragHandle> {
  bool isDragging = false;

  Widget _buildDragHandle(
    BuildContext context,
    int currentFrame,
    bool isDragging,
  ) {
    final style = widget.style ?? const FrameDragHandleStyle();
    return Container(
      width: style.width,
      height: style.height,
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: style.borderRadius ?? BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: style.textBuilder?.call(context, currentFrame.toString()) ??
          style.buildDefaultText(context, currentFrame.toString()),
    );
  }

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
        builder: (_, frameNumber, __) {
          if (widget.scrollController.offset > (frameNumber * pixelsPerFrame) + 1) {
            return SizedBox.shrink();
          }
          final style = widget.style ?? const FrameDragHandleStyle();
          return Transform.translate(
            offset: Offset(
              (frameNumber.toDouble() * pixelsPerFrame) -
                  (style.width / 2) - 
                  widget.scrollController.offset,

              0,
            ),
            child: SizedBox(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  MouseRegion(
                    opaque: false,
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
                        final parentBox =
                            context.findRenderObject() as RenderBox;
                        final localPosition = parentBox.globalToLocal(
                          event.position,
                        );

                        var currentFrame =
                            ((widget.scrollController.offset +
                                        localPosition.dx) /
                                    widget.controller.pixelsPerFrame.value)
                                .floor();
                        if (currentFrame >= 0) {
                          widget.controller.setCurrentFrame(currentFrame);
                        }
                      },
                      child: _buildDragHandle(
                        context,
                        frameNumber,
                        isDragging,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Box(style: Style($box.width(1), $box.color(style.backgroundColor))),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
