import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyframe_timeline/src/model/model.dart';
import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/shared/middle_mouse_scroll_view.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/frame_drag_handle.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/timeline_background.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/track_groups/animation_track_group/track_groups_widget.dart';
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

  const TimelineWidget({super.key, required this.controller});

  @override
  // ignore: no_logic_in_create_state
  State<TimelineWidget> createState() => _TimelineWidgetState(controller);
}

class _TimelineWidgetState<V extends AnimationTrackGroup>
    extends State<TimelineWidget> {
  final TimelineController controller;

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
  final playheadHeight = 50.0;

  Widget _scrollArea() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
        scrollbars: true,
      ),
      child: MiddleMouseScrollView(
        physics: ClampingScrollPhysics(),
        hitTestBehavior: HitTestBehavior.translucent,
        clipBehavior: Clip.hardEdge,
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: Colors.transparent,
              width:
                  controller.maxFrames.value.toDouble() *
                  controller.pixelsPerFrame.value,
            ),
          ),
        ],
      ),
    );
  }

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
                  top: playheadHeight,
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
                            Padding(
                              padding: EdgeInsets.only(top: 30),
                              child: TrackGroupsWidget(
                                trackNameWidth: trackNameWidth,
                                controller: controller,
                                horizontalScrollController:
                                    _horizontalScrollController,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              height: constraints.maxHeight,
                              right: 0,
                              left: trackNameWidth,
                              child: _scrollArea(),
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
                    playheadHeight: playheadHeight,
                    controller: controller,
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
