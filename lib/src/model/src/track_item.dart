import 'package:flutter/foundation.dart';
import 'time_range.dart';

enum TrackItemType {
  keyframe,
  clip,
  transition,
}

abstract class TrackItem {
  ValueListenable<TimeRange> get timeRange;
  
  TrackItemType get type;
  
  int get layerIndex;
  
  String get id;
  
  bool get enabled;
  
  void setEnabled(bool enabled);
  
  void setTimeRange(TimeRange range);
  
  void setLayerIndex(int index);
  
  Future<void> dispose();
  
  TrackItem clone();
}

abstract class TrackItemImpl extends TrackItem {
  @override
  final ValueNotifier<TimeRange> timeRange;
  
  @override
  final String id;
  
  @override
  int layerIndex;
  
  @override
  bool enabled;
  
  TrackItemImpl({
    required TimeRange initialTimeRange,
    required this.id,
    this.layerIndex = 0,
    this.enabled = true,
  }) : timeRange = ValueNotifier(initialTimeRange);
  
  @override
  void setEnabled(bool enabled) {
    this.enabled = enabled;
  }
  
  @override
  void setTimeRange(TimeRange range) {
    timeRange.value = range;
  }
  
  @override
  void setLayerIndex(int index) {
    layerIndex = index;
  }
  
  @override
  Future<void> dispose() async {
    timeRange.dispose();
  }
}