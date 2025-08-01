import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'channel_types.dart';
import 'keyframe.dart';
import 'base_track.dart';
import 'track_type.dart';
import 'track_item.dart';

//
// KeyframeTrack<V> contains zero or more keyframes for a given channel.
// The generic parameter [V] corresponds to the type of the values attached to
// the keyframes/channel (Vector3, Quaternion, etc).
//
abstract class KeyframeTrack<V extends ChannelValue> extends BaseTrack<AnimationTrackType> {
  //
  Type getType() => V;

  //
  // Adds a keyframe at [frameNumber] with the value [value].
  // If a keyframe already exists at [frameNumber], its value
  // is updated to [value].
  //
  Future<Keyframe<V>> addOrUpdateKeyframe(int frameNumber, V value);

  //
  // Removes the keyframe at [frameNumber]. If no keyframe exists at
  // [frameNumber], this is a noop.
  //
  Future removeKeyframeAt(int frameNumber);

  //
  // Returns the keyframe at [frame], or null if none exists.
  //
  Keyframe<V>? keyframeAt(int frame);

  //
  // Returns true if this track has a keyframe at [frame], false otherwise.
  //
  bool hasKeyframeAt(int frame);

  //
  // Returns a ValueListenable for the keyframes (computed from items).
  //
  ValueListenable<List<Keyframe<V>>> get keyframes;

  //
  // Calculates the value of this channel at [frameNumber].
  //
  // If no keyframe exists at or before [frameNumber], and [initial] is null,
  // the default ("zero") value for V will be returned. If [initial] is non-null,
  // the returned value will be calculated using the interpolation method
  // below.
  //
  // If keyframes exists both before and after [frameNumber]:
  // - the returned value will apply the respective interpolation between the
  //   first and second keyframe values. For Interpolation.constant, the first
  //   value will be returned.
  //
  V calculate(int frameNumber, {V? initial});

  //
  // The label(s) associated with each value in the track (usually an axis or
  // a channel, e.g. ["X", "Y", "Z"] or ["R", "G", "B", "A"]
  //
  List<String> get labels;

  //
  // The label for this track itself ("position", "color", "scale", etc);
  //
  String get label;

  //
  KeyframeTrack<U> cast<U extends ChannelValue>();

  //
  ValueListenable<V> get value;

  //
  void setValue(V value);
}

class KeyframeTrackImpl<V extends ChannelValue> extends BaseTrackImpl<AnimationTrackType> implements KeyframeTrack<V> {
  late final _logger = Logger(this.runtimeType.toString());

  @override
  final List<String> labels;

  @override
  late final ValueNotifier<V> value;

  final ChannelValueFactory factory;

  final List<num> defaultValues;

  KeyframeTrackImpl(
      {this.factory = const DefaultChannelValueFactory(),
      required List<Keyframe<V>> keyframes,
      required this.labels,
      required String label,
      required this.defaultValues}) : super(
    type: TrackTypes.animation,
    label: label,
    enabled: true,
    muted: false,
    locked: false,
  ) {
    final v = factory.create<V>(defaultValues);
    this.value = ValueNotifier<V>(v);
    for (final kf in keyframes) {
      kf.frameNumber.addListener(_onKeyframeFrameUpdated);
      items.value.add(kf);
    }
    items.notifyListeners();
  }

  @override
  Type getType() => V;

  @override
  ValueListenable<List<Keyframe<V>>> get keyframes {
    return _KeyframesListenable<V>(items);
  }

  @override
  KeyframeTrack<U> cast<U extends ChannelValue>() {
    return KeyframeTrackImpl<U>(
        keyframes: items.value.whereType<Keyframe<V>>().cast<Keyframe<U>>().toList(),
        labels: labels,
        label: label,
        defaultValues: defaultValues);
  }

  void _onKeyframeFrameUpdated() {
    items.notifyListeners();
  }

  @override
  Future<Keyframe<V>> addOrUpdateKeyframe(int frameNumber, V value) async {
    final keyframe = KeyframeImpl<V>(frameNumber: frameNumber, value: value);

    await addKeyframe(keyframe);
    return keyframe;
  }

  Future addKeyframe(Keyframe<V> keyframe) async {
    keyframe.frameNumber.addListener(_onKeyframeFrameUpdated);
    await removeKeyframeAt(keyframe.frameNumber.value);

    await addItem(keyframe);

    _logger.info(
      "Added keyframe at ${keyframe.frameNumber.value} with values ${keyframe.value.value.unwrap()} ",
    );
  }

  @override
  Future removeKeyframeAt(int frameNumber) async {
    final existing = keyframeAt(frameNumber);
    if (existing == null) {
      return;
    }
    
    await removeItem(existing);
  }

  @override
  Keyframe<V>? keyframeAt(int frame) {
    return items.value.whereType<Keyframe<V>>()
            .firstWhereOrNull((kf) => kf.frameNumber.value == frame);
  }

  @override
  Future dispose() async {
    for (final keyframe in items.value.whereType<Keyframe<V>>()) {
      await keyframe.dispose();
    }
    value.dispose();
    await super.dispose();
  }

  @override
  V calculate(int frameNumber, {V? initial}) {
    final keyframes = items.value.whereType<Keyframe<V>>().toList();
    if (keyframes.isEmpty) {
      return initial ?? value.value;
    }

    Keyframe? start;
    Keyframe? end;

    keyframes.sort();

    for (final kf in keyframes) {
      if (kf.frameNumber.value > frameNumber) {
        end = kf;
        break;
      }
      if (kf.frameNumber.value <= frameNumber) {
        start = kf;
      }
    }

    if (start == null) {
      return keyframes.first.value.value;
    }

    if (end == null) {
      return keyframes.last.value.value;
    }

    var linearRatio = (frameNumber - start.frameNumber.value) /
        (end.frameNumber.value - start.frameNumber.value);

    return start.interpolate(end.value.value, linearRatio) as V;
  }

  @override
  bool hasKeyframeAt(int frame) {
    return keyframeAt(frame) != null;
  }

  @override
  void setValue(V value) {
    if (this.value.value != value) {
      this.value.value = value;
    }
  }

  @override
  BaseTrack<AnimationTrackType> clone() {
    return KeyframeTrackImpl<V>(
      factory: factory,
      keyframes: items.value.whereType<Keyframe<V>>().map((kf) => KeyframeImpl<V>(
        frameNumber: kf.frameNumber.value,
        value: kf.value.value,
        interpolation: kf.interpolation.value,
      )).toList(),
      labels: List<String>.from(labels),
      label: label,
      defaultValues: List<num>.from(defaultValues),
    );
  }
}

class _KeyframesListenable<V extends ChannelValue> extends ValueListenable<List<Keyframe<V>>> {
  final ValueListenable<List<TrackItem>> _items;
  
  _KeyframesListenable(this._items);
  
  @override
  List<Keyframe<V>> get value => _items.value.whereType<Keyframe<V>>().toList();
  
  @override
  void addListener(VoidCallback listener) {
    _items.addListener(listener);
  }
  
  @override
  void removeListener(VoidCallback listener) {
    _items.removeListener(listener);
  }
}

extension KeyframeListExtension<V extends ChannelValue> on Iterable<Keyframe<V>> {
  Keyframe<V>? firstWhereOrNull(bool Function(Keyframe<V> keyframe) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
