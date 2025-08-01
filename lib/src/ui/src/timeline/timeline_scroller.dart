import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart' hide Clip;
import 'package:flutter_keyframe_timeline/src/ui/src/shared/middle_mouse_scroll_view.dart';

class TimelineScroller extends StatelessWidget {
  final Widget inner;
  final ScrollController scrollController;
  final TimelineController controller;

  const TimelineScroller({
    super.key,
    required this.inner,
    required this.controller,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
        scrollbars: true,
      ),
      child: MiddleMouseScrollView(
        physics: ClampingScrollPhysics(),
        hitTestBehavior: HitTestBehavior.translucent,
        clipBehavior: Clip.hardEdge,
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        onPrimaryMouseDown: (Offset localPosition) {
          var pixelsPerFrame = controller.pixelsPerFrame.value;
          var offset = scrollController.offset;
          var newFrame =
              (offset + localPosition.dx) / pixelsPerFrame.toDouble();
          controller.setCurrentFrame(newFrame.ceil());
        },
        slivers: [
          SliverToBoxAdapter(
            child: Listener(child:Container(
              color: Colors.transparent,
              width:
                  controller.maxFrames.value.toDouble() *
                  controller.pixelsPerFrame.value,
              child: inner,
            )),
          ),
        ],
      ),
    );
  }
}
