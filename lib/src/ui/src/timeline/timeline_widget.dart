import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyframe_timeline/src/model/model.dart';
import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';
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
  final FrameDragHandleStyle frameDragHandleStyle;
  final KeyframeIconBuilder? keyframeIconBuilder;
  final KeyframeToggleIconBuilder? keyframeToggleIconBuilder;
  final TrackGroupExtraWidgetBuilder? trackGroupExtraWidgetBuilder;

  const TimelineWidget({
    super.key,
    required this.controller,
    this.frameDragHandleStyle = const FrameDragHandleStyle(),
    this.keyframeIconBuilder,
    this.keyframeToggleIconBuilder,
    this.trackGroupExtraWidgetBuilder
  });

  @override
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

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  _TimelineWidgetState(this.controller);

  final trackNameWidth = 280.0;

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
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyUpEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.delete:
              widget.controller.deleteSelectedKeyframes();
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowLeft:
              widget.controller.setCurrentFrame(
                widget.controller.currentFrame.value - 1,
              );
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowRight:
              widget.controller.setCurrentFrame(
                widget.controller.currentFrame.value + 1,
              );
          }
        }

        return KeyEventResult.ignored;
      },
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          return TimelineBackground(
            trackNameWidth: trackNameWidth,
            controller: controller,
            scrollController: _horizontalScrollController,
            tickColor: Colors.black,
            inner: ZBox(
              style: Style($box.height(constraints.maxHeight)),
              children: [
                Positioned.fill(
                  top: widget.frameDragHandleStyle.height,
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
                            $box.color.transparent(),
                            $box.width(constraints.maxWidth),
                          ),
                          children: [
                            Positioned(
                              top: 0,
                              height: constraints.maxHeight,
                              right: 0,
                              left: trackNameWidth,
                              child: MouseRegion(
                                child: TimelineScroller(
                                  inner: Container(),
                                  controller: controller,
                                  scrollController: _horizontalScrollController,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 30),
                              child: MouseRegion(
                                hitTestBehavior: HitTestBehavior.translucent,
                                opaque: false,
                                child: Listener(
                                  behavior: HitTestBehavior.translucent,
                                  onPointerDown: (_) {
                                    _focusNode.requestFocus();
                                    widget.controller.clearSelectedKeyframes();
                                  },
                                  child: TrackGroupsWidget(
                                    trackNameWidth: trackNameWidth,
                                    controller: controller,
                                    horizontalScrollController:
                                        _horizontalScrollController,
                                    keyframeIconBuilder:
                                        widget.keyframeIconBuilder ??
                                        widget.keyframeIconBuilder ??
                                        _defaultIconBuilder,
                                    keyframeToggleIconBuilder:
                                        widget.keyframeToggleIconBuilder,
                                    trackGroupExtraWidgetBuilder: widget.trackGroupExtraWidgetBuilder,
                                  ),
                                ),
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
                    style: widget.frameDragHandleStyle
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
