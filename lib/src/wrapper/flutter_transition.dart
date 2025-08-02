import 'package:flutter/foundation.dart';
import 'package:timeline_dart/timeline_dart.dart' as dart;

/// Flutter wrapper for Transition that extends the Dart Transition
/// and provides ValueListenable interfaces for properties that need listeners
class FlutterTransition extends dart.Transition {
  late final ValueNotifier<dart.TimeRange> _timeRangeListenable;
  
  FlutterTransition({
    required dart.TransitionType transitionType,
    required dart.TimeRange timeRange,
    String? id,
    int layerIndex = 0,
    bool enabled = true,
    Map<String, dynamic> parameters = const {},
    dart.Clip? sourceClip,
    dart.Clip? targetClip,
  }) : super(
    transitionType: transitionType,
    timeRange: timeRange,
    id: id,
    layerIndex: layerIndex,
    enabled: enabled,
    parameters: parameters,
    sourceClip: sourceClip,
    targetClip: targetClip,
  ) {
    _timeRangeListenable = ValueNotifier(timeRange);
  }
  
  /// Create from existing Dart transition
  FlutterTransition.fromDart(dart.Transition dartTransition) : super(
    transitionType: dartTransition.transitionType,
    timeRange: dartTransition.timeRange,
    id: dartTransition.id,
    layerIndex: dartTransition.layerIndex,
    enabled: dartTransition.enabled,
    parameters: Map<String, dynamic>.from(dartTransition.parameters),
    sourceClip: dartTransition.sourceClip,
    targetClip: dartTransition.targetClip,
  ) {
    _timeRangeListenable = ValueNotifier(dartTransition.timeRange);
  }
  
  /// Reactive timeRange property - used by UI for listening to changes
  ValueListenable<dart.TimeRange> get timeRangeListenable => _timeRangeListenable;
  
  @override
  void setTimeRange(dart.TimeRange range) {
    super.setTimeRange(range);
    _timeRangeListenable.value = range;
  }
  
  @override
  Future<void> dispose() async {
    _timeRangeListenable.dispose();
    await super.dispose();
  }
  
  @override
  FlutterTransition clone() {
    return FlutterTransition(
      transitionType: transitionType,
      timeRange: timeRange,
      id: id,
      layerIndex: layerIndex,
      enabled: enabled,
      parameters: Map<String, dynamic>.from(parameters),
      sourceClip: sourceClip,
      targetClip: targetClip,
    );
  }
}