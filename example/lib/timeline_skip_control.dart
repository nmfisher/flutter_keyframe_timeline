import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';

class TimelineSkipControl extends StatelessWidget {
  final TimelineController timelineController;
  final double width;

  const TimelineSkipControl({
    super.key,
    required this.timelineController,
    this.width = 80.0,
  });

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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 32, minHeight: 24),
            icon: Icon(Icons.skip_previous, size: 16, color: Colors.white),
            onPressed: () => timelineController.skipToStart(),
            tooltip: 'Skip to Start',
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 32, minHeight: 24),
            icon: Icon(Icons.skip_next, size: 16, color: Colors.white),
            onPressed: () => timelineController.skipToEnd(),
            tooltip: 'Skip to End',
          ),
        ],
      ),
    );
  }
}