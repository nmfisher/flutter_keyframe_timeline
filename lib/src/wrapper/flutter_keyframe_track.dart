import 'package:flutter/foundation.dart';
import 'package:timeline_dart/timeline_dart.dart' as dart;

/// Flutter wrapper for KeyframeTrack that extends the Dart KeyframeTrack
/// and provides ValueListenable interfaces for properties that need listeners
class FlutterKeyframeTrack<V extends dart.ChannelValue> extends dart.KeyframeTrackImpl<V> {
  late final ValueNotifier<List<dart.Keyframe<V>>> _keyframesListenable;
  late final ValueNotifier<V> _valueListenable;
  
  FlutterKeyframeTrack({
    dart.ChannelValueFactory factory = const dart.DefaultChannelValueFactory(),
    required List<dart.Keyframe<V>> keyframes,
    required List<String> labels,
    required String label,
    required List<num> defaultValues,
  }) : super(
    factory: factory,
    keyframes: keyframes,
    labels: labels,
    label: label,
    defaultValues: defaultValues,
  ) {
    _keyframesListenable = ValueNotifier(this.keyframes);
    _valueListenable = ValueNotifier(this.value);
  }
  
  /// Create from existing Dart keyframe track
  FlutterKeyframeTrack.fromDart(dart.KeyframeTrackImpl<V> dartTrack) : super(
    factory: dartTrack.factory,
    keyframes: dartTrack.items.whereType<dart.Keyframe<V>>().toList(),
    labels: dartTrack.labels,
    label: dartTrack.label,
    defaultValues: dartTrack.defaultValues,
  ) {
    _keyframesListenable = ValueNotifier(this.keyframes);
    _valueListenable = ValueNotifier(this.value);
  }
  
  /// Reactive keyframes property - used by UI for listening to changes
  ValueListenable<List<dart.Keyframe<V>>> get keyframesListenable => _keyframesListenable;
  
  /// Reactive value property - used by UI for listening to changes
  ValueListenable<V> get valueListenable => _valueListenable;
  
  @override
  Future<dart.Keyframe<V>> addOrUpdateKeyframe(int frameNumber, V value) async {
    final result = await super.addOrUpdateKeyframe(frameNumber, value);
    _syncKeyframes();
    return result;
  }
  
  @override
  Future removeKeyframeAt(int frameNumber) async {
    await super.removeKeyframeAt(frameNumber);
    _syncKeyframes();
  }
  
  @override
  void setValue(V value) {
    super.setValue(value);
    _valueListenable.value = value;
  }
  
  /// Sync the reactive properties with the underlying model
  void _syncKeyframes() {
    _keyframesListenable.value = keyframes;
  }
  
  @override
  Future<void> addItem(dart.TrackItem item) async {
    await super.addItem(item);
    _syncKeyframes();
  }
  
  @override
  Future<void> removeItem(dart.TrackItem item) async {
    await super.removeItem(item);
    _syncKeyframes();
  }
  
  @override
  Future<void> dispose() async {
    _keyframesListenable.dispose();
    _valueListenable.dispose();
    await super.dispose();
  }
  
  @override
  FlutterKeyframeTrack<V> clone() {
    return FlutterKeyframeTrack<V>(
      factory: const dart.DefaultChannelValueFactory(),
      keyframes: items.whereType<dart.Keyframe<V>>().map((kf) => kf.clone() as dart.Keyframe<V>).toList(),
      labels: List<String>.from(labels),
      label: label,
      defaultValues: List<num>.from(defaultValues),
    );
  }
}