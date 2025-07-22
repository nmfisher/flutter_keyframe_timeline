import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/track_groups/animation_track_group/track_group_widget.dart';
import 'package:mix/mix.dart';

class TrackGroupsWidget extends StatelessWidget {
  final TimelineController controller;
  final ScrollController horizontalScrollController;
  final double trackNameWidth;

  const TrackGroupsWidget({
    super.key,
    required this.controller,
    required this.horizontalScrollController,
    required this.trackNameWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: ValueListenableBuilder(
        valueListenable: controller.trackGroups,
        builder: (_, groups, __) => VBox(
          key: ObjectKey(controller.trackGroups),
          style: Style($flex.crossAxisAlignment.start()),
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
                    trackNameWidth: trackNameWidth,
                    scrollController: horizontalScrollController,
                  ),
                ),
              )
              .values
              .cast<Widget>()
              .toList(),
        ),
      ),
    );

  }
}


  // Widget _trackGroupKeyframeTracks(BuildContext context) {
  //   final width = (controller.maxFrames.value * controller.pixelsPerFrame.value)
  //       .toDouble();
  //   final height = 100.0;

  //   return SizedBox(
  //     height: controller.trackGroups.value.length * 50,
  //     child: ScrollConfiguration(
  //       behavior: ScrollConfiguration.of(context).copyWith(
  //         dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
  //         scrollbars: true,
  //       ),
  //       child: Stack(
  //         children: [
  //           Positioned.fill(
  //             child: MiddleMouseScrollView(
  //               physics: ClampingScrollPhysics(),
  //               hitTestBehavior: HitTestBehavior.translucent,
  //               clipBehavior: Clip.hardEdge,
  //               controller: showTrackKeyframes
  //                   ? horizontalScrollController
  //                   : null,
  //               scrollDirection: Axis.horizontal,
  //               slivers: [
  //                 SliverToBoxAdapter(
  //                   child: SizedBox(
  //                     width: width,
  //                     child: Stack(
  //                       children: [
  //                         Positioned(
  //                           left: 0,
  //                           width: width,
  //                           // top: 0,
  //                           // bottom: 0,
  //                           height: height,
  //                           child: TimelineBackground(
  //                             controller: controller,
  //                             tickColor: Colors.black,
  //                           ),
  //                         ),
  //                         KeyframeTrackListWidget(controller: controller),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }