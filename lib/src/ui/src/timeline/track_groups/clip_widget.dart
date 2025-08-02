import 'package:flutter/material.dart';
import 'package:timeline_dart/timeline_dart.dart' as dart;
import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';
import 'package:flutter_keyframe_timeline/src/wrapper/flutter_video_track.dart';
import 'package:flutter_keyframe_timeline/src/wrapper/wrapper_factory.dart' as wrapper;

class ClipWidget extends StatefulWidget {
  final FlutterVideoTrack videoTrack;
  final TimelineController controller;
  final ScrollController scrollController;

  const ClipWidget({
    super.key,
    required this.videoTrack,
    required this.controller,
    required this.scrollController,
  });

  @override
  State<ClipWidget> createState() => _ClipWidgetState();
}

class _ClipWidgetState extends State<ClipWidget> {
  Offset? dragStart;
  int initialStartFrame = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.videoTrack.itemsListenable,
      builder: (_, items, __) {
        final clips = items.whereType<dart.Clip>().toList();
        return SizedBox(
          height: 40,
          child: Stack(
            children: [
              // Background track
              Container(
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              // Render clips
              ...clips.map((clip) => _buildClipWidget(clip)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClipWidget(dart.Clip clip) {
    final flutterClip = wrapper.WrapperFactory.wrapClip(clip);
    
    return ValueListenableBuilder(
      valueListenable: flutterClip.timeRangeListenable,
      builder: (_, timeRange, __) {
        return ValueListenableBuilder(
          valueListenable: widget.controller.pixelsPerFrame,
          builder: (_, pixelsPerFrame, __) {
            final startFrame = timeRange.startFrame;
            final endFrame = timeRange.endFrame;

            final left = startFrame.toDouble() * pixelsPerFrame;
            final width = (endFrame - startFrame) * pixelsPerFrame.toDouble();

            return Positioned(
              left: left,
              top: 5,
              width: width,
              height: 30,
              child: ValueListenableBuilder(
                valueListenable: widget.controller.active,
                builder: (_, active, __) {
                  final isActive = active.contains(clip);
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onPanStart: (details) {
                      dragStart = details.localPosition;
                      initialStartFrame = startFrame;
                    },
                    onTap: () {
                      // TODO: Handle clip selection - clips are track items, not timeline objects
                    },
                    onPanUpdate: (details) {
                      if (dragStart != null) {
                        final dragDelta = details.localPosition.dx - dragStart!.dx;
                        final frameDelta = (dragDelta / pixelsPerFrame).round();
                        
                        if (frameDelta != 0) {
                          final newStartFrame = initialStartFrame + frameDelta;
                          final newEndFrame = newStartFrame + (endFrame - startFrame);
                          clip.setTimeRange(dart.TimeRange(
                            startFrame: newStartFrame,
                            endFrame: newEndFrame,
                          ));
                        }
                      }
                    },
                    onPanEnd: (_) {
                      dragStart = null;
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 1, right: 1, top: 2, bottom: 2),
                      decoration: BoxDecoration(
                        color: isActive 
                            ? Colors.purple.withValues(alpha: 0.8)
                            : Colors.purple.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isActive
                              ? Colors.purple.shade900
                              : Colors.purple.shade700,
                          width: isActive ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Left drag handle
                          Container(
                            width: 12,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.purple.shade900.withValues(alpha: 0.5),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                bottomLeft: Radius.circular(4),
                              ),
                            ),
                          ),

                          // Clip content
                          Expanded(
                            child: Center(
                              child: Text(
                                clip.source.path.split('/').last,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),

                          // Right drag handle
                          Container(
                            width: 12,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.purple.shade900.withValues(alpha: 0.5),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(4),
                                bottomRight: Radius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}