import 'package:flutter/foundation.dart';
import 'package:timeline_dart/timeline_dart.dart' as dart;

/// Flutter wrapper for Clip that extends the Dart Clip
/// and provides ValueListenable interfaces for properties that need listeners
class FlutterClip extends dart.Clip {
  late final ValueNotifier<dart.TimeRange> _timeRangeListenable;
  late final ValueNotifier<double> _opacityListenable;
  late final ValueNotifier<bool> _visibleListenable;
  
  FlutterClip({
    required dart.MediaSource source,
    required dart.TimeRange trackRange,
    dart.TimeRange? sourceRange,
    String? id,
    int layerIndex = 0,
    bool enabled = true,
    Map<String, dynamic> effects = const {},
    double opacity = 1.0,
    bool visible = true,
  }) : super(
    source: source,
    trackRange: trackRange,
    sourceRange: sourceRange,
    id: id,
    layerIndex: layerIndex,
    enabled: enabled,
    effects: effects,
    opacity: opacity,
    visible: visible,
  ) {
    _timeRangeListenable = ValueNotifier(trackRange);
    _opacityListenable = ValueNotifier(opacity);
    _visibleListenable = ValueNotifier(visible);
  }
  
  /// Create from existing Dart clip
  FlutterClip.fromDart(dart.Clip dartClip) : super(
    source: dartClip.source,
    trackRange: dartClip.timeRange,
    sourceRange: dartClip.sourceRange,
    id: dartClip.id,
    layerIndex: dartClip.layerIndex,
    enabled: dartClip.enabled,
    effects: Map<String, dynamic>.from(dartClip.effects),
    opacity: dartClip.opacity,
    visible: dartClip.visible,
  ) {
    _timeRangeListenable = ValueNotifier(dartClip.timeRange);
    _opacityListenable = ValueNotifier(dartClip.opacity);
    _visibleListenable = ValueNotifier(dartClip.visible);
  }
  
  /// Reactive timeRange property - used by UI for listening to changes
  ValueListenable<dart.TimeRange> get timeRangeListenable => _timeRangeListenable;
  
  /// Reactive opacity property - used by UI for listening to changes
  ValueListenable<double> get opacityListenable => _opacityListenable;
  
  /// Reactive visible property - used by UI for listening to changes
  ValueListenable<bool> get visibleListenable => _visibleListenable;
  
  @override
  void setTimeRange(dart.TimeRange range) {
    super.setTimeRange(range);
    _timeRangeListenable.value = range;
  }
  
  @override
  void setOpacity(double opacity) {
    super.setOpacity(opacity);
    _opacityListenable.value = this.opacity;
  }
  
  @override
  void setVisible(bool visible) {
    super.setVisible(visible);
    _visibleListenable.value = visible;
  }
  
  @override
  Future<void> dispose() async {
    _timeRangeListenable.dispose();
    _opacityListenable.dispose();
    _visibleListenable.dispose();
    await super.dispose();
  }
  
  @override
  FlutterClip clone() {
    return FlutterClip(
      source: source,
      trackRange: timeRange,
      sourceRange: sourceRange,
      id: id,
      layerIndex: layerIndex,
      enabled: enabled,
      effects: Map<String, dynamic>.from(effects),
      opacity: opacity,
      visible: visible,
    );
  }
}