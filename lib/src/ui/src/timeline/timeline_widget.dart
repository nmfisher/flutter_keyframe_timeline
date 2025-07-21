import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyframe_timeline/src/model/model.dart';
import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/shared/middle_mouse_scroll_view.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/frame_drag_handle.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/timeline_background.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/track_groups/animation_track_group/track_group_widget.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/track_groups/keyframe_track_list_widget.dart';
import 'package:mix/mix.dart';

// Displays a vertical list of all objects of type [V] (each of which is assumed to
// have animation channels).
//
// When the object name is clicked, the outer entry expands to show a vertical
// list of animation tracks for the respective model.
//
// Each entry in this inner list displays an editor for the values in that track.
//
class TimelineWidget<V extends AnimationTrackGroup> extends StatefulWidget {
  final TimelineController<V> controller;

  const TimelineWidget({super.key, required this.controller});

  @override
  // ignore: no_logic_in_create_state
  State<TimelineWidget> createState() => _TimelineWidgetState<V>(controller);
}

class _TimelineWidgetState<V extends AnimationTrackGroup>
    extends State<TimelineWidget> {
  final TimelineController<V> controller;

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

  Widget _trackGroupNameList() {
    return Container(
      color: Colors.transparent,
      child: ValueListenableBuilder(valueListenable: controller.trackGroups, builder: (_, groups, __) => Column(
        key: ObjectKey(controller.trackGroups),
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: groups
            .asMap()
            .map(
              (idx, group) => MapEntry(
                idx,
                TrackGroupWidget(
                  key: ObjectKey(group),
                  group: group,
                  index: idx,
                  controller: controller,
                ),
              ),
            )
            .values
            .cast<Widget>()
            .toList(),
      )),
    );
  }

  final trackNameWidth = 280.0;
  final trackHeight = 50.0;
  final playheadHeight = 50.0;

  Widget _trackGroupKeyframeTracks() {
    final width =
        (widget.controller.maxFrames.value *
                widget.controller.pixelsPerFrame.value)
            .toDouble();
    final height = (widget.controller.trackGroups.value.length * trackHeight);

    return SizedBox(
      height: controller.trackGroups.value.length * 50,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
          scrollbars: true,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: MiddleMouseScrollView(
                physics: ClampingScrollPhysics(),
                hitTestBehavior: HitTestBehavior.translucent,
                clipBehavior: Clip.hardEdge,
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      width: width,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            width: width,
                            // top: 0,
                            // bottom: 0,
                            height: height,
                            child: TimelineBackground(
                              controller: controller,
                              tickColor: Colors.black,
                            ),
                          ),
                          KeyframeTrackListWidget(controller: controller),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
        Positioned.fill(
          top: playheadHeight,
          child: CustomScrollView(
            physics: ClampingScrollPhysics(),
            hitTestBehavior: HitTestBehavior.translucent,
            scrollDirection: Axis.vertical,
            shrinkWrap: false,
            slivers: [
              SliverToBoxAdapter(
                child: HBox(
                  style: Style($flex.crossAxisAlignment.start()),
                  children: [
                    SizedBox(
                      width: trackNameWidth,
                      child: _trackGroupNameList(),
                    ),
                    Expanded(child: _trackGroupKeyframeTracks()),
                  ],
                ),
              ),
            ],
          ),
        ),
        
      ],
    );
  }
}
