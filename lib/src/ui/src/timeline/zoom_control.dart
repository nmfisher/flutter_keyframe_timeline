import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';

class TimelineZoomControl extends StatelessWidget {
  final TimelineController timelineController;
  final double width;

  const TimelineZoomControl({
    super.key,
    required this.timelineController,
    this.width = 120.0,
  });

  void _incrementZoom() {
    // Get current zoom level based on pixels per frame
    double currentZoom = (timelineController.pixelsPerFrame.value - 1) / 9;
    double newZoom = (currentZoom + 0.1).clamp(0.0, 1.0);
    timelineController.setZoomLevel(newZoom);
  }

  void _decrementZoom() {
    double currentZoom = (timelineController.pixelsPerFrame.value - 1) / 9;
    double newZoom = (currentZoom - 0.1).clamp(0.0, 1.0);
    timelineController.setZoomLevel(newZoom);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 32, minHeight: 24),
            icon: Icon(Icons.remove, size: 16, color: Colors.white),
            onPressed: _decrementZoom,
          ),
          ValueListenableBuilder<int>(
            valueListenable: timelineController.pixelsPerFrame,
            builder: (context, pixelsPerFrame, child) {
              int percentage = (((pixelsPerFrame - 1) / 9) * 100).round();
              return Text(
                '$percentage%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              );
            },
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 32, minHeight: 24),
            icon: Icon(Icons.add, size: 16, color: Colors.white),
            onPressed: _incrementZoom,
          ),
        ],
      ),
    );
  }
}