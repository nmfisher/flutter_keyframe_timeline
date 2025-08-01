import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_keyframe_timeline/src/model/model.dart';
import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';

class ClipWidget extends StatelessWidget {
  final VideoTrack videoTrack;
  final TimelineController controller;
  final ScrollController scrollController;

  const ClipWidget({
    super.key,
    required this.videoTrack,
    required this.controller,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: videoTrack.items,
      builder: (_, items, __) {
        return SizedBox(
          height: 40,
          child: Stack(
            children: [
              // Background track
              Container(
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              
              // Render clips
              ...items.whereType<Clip>().map((clip) => _buildClipWidget(clip)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClipWidget(Clip clip) {
    return ValueListenableBuilder(
      valueListenable: clip.timeRange,
      builder: (_, timeRange, __) {
        final startFrame = timeRange.startFrame;
        final endFrame = timeRange.endFrame;
        final pixelsPerFrame = controller.pixelsPerFrame.value;
        
        final left = startFrame.toDouble() * pixelsPerFrame;
        final width = (endFrame - startFrame) * pixelsPerFrame.toDouble();
        
        return Positioned(
          left: left,
          top: 5,
          width: width,
          height: 30,
          child: ValueListenableBuilder(
            valueListenable: controller.active,
            builder: (_, active, __) {
              final isActive = active.contains(clip);
              return GestureDetector(
                onTap: () {
                  // Handle clip selection
                },
                onPanUpdate: (details) {
                  // Drag to move clip
                  final frameDelta = (details.delta.dx / pixelsPerFrame).round();
                  if (frameDelta != 0) {
                    final newStartFrame = (startFrame + frameDelta).clamp(0, 1000);
                    final newEndFrame = newStartFrame + (endFrame - startFrame);
                    clip.setTimeRange(TimeRange(
                      startFrame: newStartFrame,
                      endFrame: newEndFrame,
                    ));
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isActive ? Colors.blue.withOpacity(0.8) : Colors.blue.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isActive ? Colors.blue.shade900 : Colors.blue.shade700,
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Left drag handle
                      GestureDetector(
                        onPanUpdate: (details) {
                          // Resize from left
                          final frameDelta = (details.delta.dx / pixelsPerFrame).round();
                          if (frameDelta != 0) {
                            final newStartFrame = (startFrame + frameDelta).clamp(0, endFrame - 1);
                            clip.setTimeRange(TimeRange(
                              startFrame: newStartFrame,
                              endFrame: endFrame,
                            ));
                          }
                        },
                        child: Container(
                          width: 8,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade900.withOpacity(0.5),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4),
                              bottomLeft: Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      
                      // Clip content
                      Expanded(
                        child: Center(
                          child: Text(
                            '${clip.source.path.split('/').last}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      
                      // Right drag handle
                      GestureDetector(
                        onPanUpdate: (details) {
                          // Resize from right
                          final frameDelta = (details.delta.dx / pixelsPerFrame).round();
                          if (frameDelta != 0) {
                            final newEndFrame = (endFrame + frameDelta).clamp(startFrame + 1, startFrame + 1000);
                            clip.setTimeRange(TimeRange(
                              startFrame: startFrame,
                              endFrame: newEndFrame,
                            ));
                          }
                        },
                        child: Container(
                          width: 8,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade900.withOpacity(0.5),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            ),
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
  }
}