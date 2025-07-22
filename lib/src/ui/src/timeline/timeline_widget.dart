import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyframe_timeline/src/model/model.dart';
import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/shared/middle_mouse_scroll_view.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/frame_drag_handle.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/timeline_background.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/timeline_scroller.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/track_groups/animation_track_group/track_groups_widget.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/timeline_style.dart';
import 'package:mix/mix.dart';

// Displays a vertical list of all objects of type [V] (each of which is assumed to
// have animation channels).
//
// When the object name is clicked, the outer entry expands to show a vertical
// list of animation tracks for the respective model.
//
// Each entry in this inner list displays an editor for the values in that track.
//
class TimelineWidget extends StatefulWidget {
  final TimelineController controller;
  final TimelineStyle? style;
  final KeyframeIconBuilder? keyframeIconBuilder;
  final FrameDragHandleBuilder? frameDragHandleBuilder;

  const TimelineWidget({
    super.key,
    required this.controller,
    this.style,
    this.keyframeIconBuilder,
    this.frameDragHandleBuilder,
  });

  @override
  // ignore: no_logic_in_create_state
  State<TimelineWidget> createState() => _TimelineWidgetState(controller);
}

class _TimelineWidgetState<V extends AnimationTrackGroup>
    extends State<TimelineWidget> {
  final TimelineController controller;

  static Widget _defaultIconBuilder(
    BuildContext context,
    bool isSelected,
    bool isHovered,
    int frameNumber,
  ) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isSelected ? Colors.amber.withOpacity(0.2) : Colors.black,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            border: Border.all(width: isHovered || isSelected ? 2 : 1),
            boxShadow: isSelected
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
    );
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {});
  }

  final _horizontalScrollController = ScrollController();

  late final _focusNode = FocusNode();

  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _focusNode.dispose();
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  _TimelineWidgetState(this.controller);

  bool _onKey(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      HardwareKeyboard.instance.removeHandler(_onKey);
      return true;
    }
    return false;
  }

  final trackNameWidth = 280.0;
  final trackHeight = 50.0;

  //
  // The z-ordering and scroll implementation can be a bit tricky to follow.
  // At a high level:
  // - the list of objects appears are on the left
  // - the actual keyframes for each object/track appear on the right
  // - both containers scroll vertically
  // - only the actual keyframes container widget on the right can scroll
  //  horizontally, including
  // - the current frame indicator is always on top, but will only be translated
  //   to match the horizontal scroll; this will never scroll vertically.)
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return TimelineBackground(
          trackNameWidth: trackNameWidth,
          controller: controller,
          scrollController: _horizontalScrollController,
          tickColor: Colors.black,
          inner: SizedBox(
            height: constraints.maxHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  top: widget.style?.frameDragHandleStyle.height ?? 50.0,
                  child: CustomScrollView(
                    physics: ClampingScrollPhysics(),
                    hitTestBehavior: HitTestBehavior.translucent,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: false,
                    slivers: [
                      SliverToBoxAdapter(
                        child: ZBox(
                          style: Style(
                            $box.clipBehavior.none(),
                            $box.height(constraints.maxHeight),
                            $box.width(constraints.maxWidth),
                          ),
                          children: [
                            Positioned(
                              top: 0,
                              height: constraints.maxHeight,
                              right: 0,
                              left: trackNameWidth,
                              child: TimelineScroller(
                                inner: Container(color: Colors.transparent),
                                controller: controller,
                                scrollController: _horizontalScrollController,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 30),
                              child: TrackGroupsWidget(
                                trackNameWidth: trackNameWidth,
                                controller: controller,
                                horizontalScrollController:
                                    _horizontalScrollController,
                                keyframeIconBuilder:
                                    widget.keyframeIconBuilder ??
                                    widget.style?.keyframeIconBuilder ??
                                    _defaultIconBuilder,
                                keyframeToggleIconBuilder:
                                    widget.style?.keyframeToggleIconBuilder,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: trackNameWidth,
                  child: FrameDragHandle(
                    scrollController: _horizontalScrollController,
                    controller: controller,
                    frameDragHandleBuilder: widget.frameDragHandleBuilder,
                    style: widget.style?.frameDragHandleStyle,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
