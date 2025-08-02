import 'package:flutter/foundation.dart';
import 'package:timeline_dart/timeline_dart.dart' as dart;

/// Flutter wrapper for Keyframe that extends the Dart Keyframe
/// and provides ValueListenable interfaces for properties that need listeners
class FlutterKeyframe<V extends dart.ChannelValue> extends dart.KeyframeImpl<V> {
  late final ValueNotifier<int> _frameNumberListenable;
  late final ValueNotifier<V> _valueListenable;
  late final ValueNotifier<dart.Interpolation> _interpolationListenable;
  
  FlutterKeyframe({
    required int frameNumber,
    required V value,
    dart.Interpolation interpolation = dart.Interpolation.linear,
    String? id,
    int layerIndex = 0,
    bool enabled = true,
  }) : super(
    frameNumber: frameNumber,
    value: value,
    interpolation: interpolation,
    id: id,
    layerIndex: layerIndex,
    enabled: enabled,
  ) {
    _frameNumberListenable = ValueNotifier(frameNumber);
    _valueListenable = ValueNotifier(value);
    _interpolationListenable = ValueNotifier(interpolation);
  }
  
  /// Create from existing Dart keyframe
  FlutterKeyframe.fromDart(dart.KeyframeImpl<V> dartKeyframe) : super(
    frameNumber: dartKeyframe.frameNumber,
    value: dartKeyframe.value,
    interpolation: dartKeyframe.interpolation,
    id: dartKeyframe.id,
    layerIndex: dartKeyframe.layerIndex,
    enabled: dartKeyframe.enabled,
  ) {
    _frameNumberListenable = ValueNotifier(dartKeyframe.frameNumber);
    _valueListenable = ValueNotifier(dartKeyframe.value);
    _interpolationListenable = ValueNotifier(dartKeyframe.interpolation);
  }
  
  /// Reactive frameNumber property - used by UI for listening to changes
  ValueListenable<int> get frameNumberListenable => _frameNumberListenable;
  
  /// Reactive value property - used by UI for listening to changes
  ValueListenable<V> get valueListenable => _valueListenable;
  
  /// Reactive interpolation property - used by UI for listening to changes
  ValueListenable<dart.Interpolation> get interpolationListenable => _interpolationListenable;
  
  @override
  Future setFrameNumber(int frameNumber) async {
    await super.setFrameNumber(frameNumber);
    _frameNumberListenable.value = frameNumber;
  }
  
  /// Update the value and notify listeners
  void updateValue(V newValue) {
    super.value = newValue;
    _valueListenable.value = newValue;
  }
  
  /// Update the interpolation and notify listeners
  void updateInterpolation(dart.Interpolation newInterpolation) {
    super.interpolation = newInterpolation;
    _interpolationListenable.value = newInterpolation;
  }
  
  @override
  Future<void> dispose() async {
    _frameNumberListenable.dispose();
    _valueListenable.dispose();
    _interpolationListenable.dispose();
    await super.dispose();
  }
  
  @override
  FlutterKeyframe<V> clone() {
    return FlutterKeyframe<V>(
      frameNumber: frameNumber,
      value: value,
      interpolation: interpolation,
      layerIndex: layerIndex,
      enabled: enabled,
    );
  }
}