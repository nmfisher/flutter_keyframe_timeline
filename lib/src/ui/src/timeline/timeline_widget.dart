import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timeline_dart/timeline_dart.dart';
import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/frame_drag_handle.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/timeline_background.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/timeline_scroller.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/track_groups/track_objects_widget.dart';
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

  /// Styling for the keyframe widget/icon that appears in the timeline.
  final KeyframeIconBuilder keyframeIconBuilder;

  /// Styling for the add/remove keyframe icon that appears in the object list.
  final KeyframeToggleIconBuilder keyframeToggleIconBuilder;

  final TrackObjectExtraWidgetBuilder? trackObjectExtraWidgetBuilder;
  final TrackObjectNameStyle? trackObjectNameStyle;
  final TimelineBackgroundStyle backgroundStyle;

  /// Styling for the text fields used to edit the numeric values for
  /// each channel in an Track.
  ///
  /// This controls the visual appearance of the TextField widgets used for editing
  /// animation channel values (like position X, Y, Z coordinates). You can customize:
  /// - Text color and font size
  /// - Background and border colors
  /// - Complete InputDecoration for full control over appearance
  ///
  /// This only affects the TextField styling, not the layout or wrapper behavior.
  final ChannelValueEditorStyle? channelValueEditorStyle;

  /// Builder for wrapping channel value editor text fields.
  ///
  /// This allows you to customize the layout and wrapper behavior around each
  /// TextField used for editing channel values. The builder receives:
  /// - The styled TextField widget (already configured with channelValueEditorStyle)
  /// - The TextEditingController for manipulating the text value externally
  /// - The dimension label (e.g., "X", "Y", "Z")
  /// - The dimension index (0, 1, 2, etc.)
  ///
  /// Use this to add labels, containers, spacing, or other UI elements around
  /// the text fields. The controller allows external manipulation of the text
  /// value (e.g., via mouse drag interactions). If null, text fields are
  /// wrapped in a simple SizedBox.
  ///
  /// Note: This only controls the wrapper/layout - the TextField styling is
  /// handled separately by channelValueEditorStyle.
  final ChannelValueTextFieldWidgetBuilder? channelValueEditorContainerBuilder;

  /// Styling for the lines connecting consecutive keyframes in the timeline.
  final KeyframeConnectionStyle keyframeConnectionStyle;

  const TimelineWidget({
    super.key,
    required this.controller,
    this.frameDragHandleStyle = const FrameDragHandleStyle(),
    this.keyframeIconBuilder = kDefaultKeyframeIconBuilder,
    this.keyframeToggleIconBuilder = kDefaultKeyframeToggleIconBuilder,
    this.trackObjectExtraWidgetBuilder,
    this.trackObjectNameStyle,
    this.backgroundStyle = const TimelineBackgroundStyle(),
    this.channelValueEditorStyle,
    this.channelValueEditorContainerBuilder,
    this.keyframeConnectionStyle = const KeyframeConnectionStyle(),
  });

  @override
  State<TimelineWidget> createState() => _TimelineWidgetState(controller);
}

class _TimelineWidgetState<V extends TimelineObject>
    extends State<TimelineWidget> {
  final TimelineController controller;

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
            backgroundStyle: widget.backgroundStyle,
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
                              child: TimelineScroller(
                                inner: Container(
                                  color: Colors.transparent,
                                ),
                                controller: controller,
                                scrollController: _horizontalScrollController,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 30),
                              child: MouseRegion(
                                hitTestBehavior: HitTestBehavior.translucent,
                                opaque: true,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    _focusNode.requestFocus();
                                    widget.controller.clearSelectedKeyframes();
                                  },
                                  child: TrackObjectsWidget(
                                    trackNameWidth: trackNameWidth,
                                    controller: controller,
                                    horizontalScrollController:
                                        _horizontalScrollController,
                                    keyframeIconBuilder:
                                        widget.keyframeIconBuilder,
                                    keyframeToggleIconBuilder:
                                        widget.keyframeToggleIconBuilder,
                                    trackObjectExtraWidgetBuilder:
                                        widget.trackObjectExtraWidgetBuilder,
                                    trackObjectNameStyle:
                                        widget.trackObjectNameStyle,
                                    channelValueEditorStyle:
                                        widget.channelValueEditorStyle,
                                    channelValueEditorContainerBuilder: widget
                                        .channelValueEditorContainerBuilder,
                                    keyframeConnectionStyle:
                                        widget.keyframeConnectionStyle,
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
                      style: widget.frameDragHandleStyle),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
