import 'package:flutter/foundation.dart';
import 'package:timeline_dart/timeline_dart.dart' as dart;

/// Flutter wrapper for TrackItem that provides ValueListenable interfaces
class FlutterTrackItem {
  final dart.TrackItem _dartModel;
  late final ValueNotifier<dart.TimeRange> _timeRange;
  
  /// Protected access to the underlying Dart model for subclasses
  @protected
  dart.TrackItem get dartModel => _dartModel;
  
  /// Protected access to the reactive timeRange for subclasses
  @protected
  ValueNotifier<dart.TimeRange> get timeRangeNotifier => _timeRange;
  
  FlutterTrackItem(this._dartModel) {
    _timeRange = ValueNotifier(_dartModel.timeRange);
  }
  
  /// Reactive timeRange property
  ValueListenable<dart.TimeRange> get timeRange => _timeRange;
  
  @override
  dart.TrackItemType get type => _dartModel.type;
  
  @override
  int get layerIndex => _dartModel.layerIndex;
  
  @override
  String get id => _dartModel.id;
  
  @override
  bool get enabled => _dartModel.enabled;
  
  @override
  void setEnabled(bool enabled) {
    _dartModel.setEnabled(enabled);
  }
  
  @override
  void setTimeRange(dart.TimeRange range) {
    _dartModel.setTimeRange(range);
    _timeRange.value = range;
  }
  
  @override
  void setLayerIndex(int index) {
    _dartModel.setLayerIndex(index);
  }
  
  @override
  Future<void> dispose() async {
    _timeRange.dispose();
    await _dartModel.dispose();
  }
  
  @override
  dart.TrackItem clone() {
    // Return the underlying Dart model's clone - the consumer will need to wrap it
    return _dartModel.clone();
  }
  
}

