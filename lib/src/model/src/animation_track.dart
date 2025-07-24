import 'package:flutter/foundation.dart';
import 'package:flutter_keyframe_timeline/src/model/src/timeline_serializer.dart';
import 'package:logging/logging.dart';
import 'channel_types.dart';
import 'keyframe.dart';

//
// AnimationTrack<V> contains zero or more keyframes for a given channel.
// The generic parameter [V] corresponds to the type of the values attached to
// the keyframes/channel (Vector3, Quaternion, etc).
//
abstract class AnimationTrack<V extends ChannelValueType> {
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
  // A map of frame numbers to keyframes.
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
  Future dispose();
}

class AnimationTrackImpl<V extends ChannelValueType> extends AnimationTrack<V> {
  static final _logger = Logger("AnimationTrackImpl");

  @override
  final ValueNotifier<List<Keyframe<V>>> keyframes =
      ValueNotifier<List<Keyframe<V>>>([]);

  @override
  final List<String> labels;

  @override
  final String label;

  TimelineSerializer? serializer;

  AnimationTrackImpl(
    List<Keyframe<V>> keyframes,
    this.labels,
    this.label, {
    this.serializer,
  }) {
    for (final kf in keyframes) {
      this.keyframes.value.add(kf);
      kf.frameNumber.addListener(_onKeyframeFrameUpdated);
    }
  }

  void _onKeyframeFrameUpdated() {
    this.keyframes.notifyListeners();
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
    keyframes.value.add(keyframe);

    keyframes.notifyListeners();
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
    await existing?.dispose();
    keyframes.value.remove(existing);
    keyframes.notifyListeners();
  }

  @override
  Keyframe<V>? keyframeAt(int frame) {
    return keyframes.value
            .firstWhereOrNull((kf) => kf.frameNumber.value == frame)
        as Keyframe<V>?;
  }

  @override
  Future dispose() async {
    for (final keyframe in keyframes.value) {
      keyframe.dispose();
    }
    keyframes.value.clear();
    keyframes.dispose();
  }

  @override
  V calculate(int frameNumber, {V? initial}) {
    if (keyframes.value.isEmpty) {
      return initial ?? this.serializer!.defaultZero();
    }

    Keyframe? start;
    Keyframe? end;

    keyframes.value.sort();

    for (final kf in keyframes.value) {
      if (kf.frameNumber.value > frameNumber) {
        end = kf;
        break;
      }
      if (kf.frameNumber.value <= frameNumber) {
        start = kf;
      }
    }

    if (start == null) {
      return keyframes.value.first.value.value;
    }

    if (end == null) {
      return keyframes.value.last.value.value;
    }

    var linearRatio = (frameNumber - start.frameNumber.value) /
        (end.frameNumber.value - start.frameNumber.value);

    return start.interpolate(end.value.value, linearRatio) as V;
  }

  @override
  bool hasKeyframeAt(int frame) {
    return keyframeAt(frame) != null;
  }
}

extension on List<Keyframe> {
  Keyframe? firstWhereOrNull(bool Function(dynamic keyframe) param0) {
    return cast<Keyframe?>().firstWhere(param0, orElse: () => null);
  }
}
