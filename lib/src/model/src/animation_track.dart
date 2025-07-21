import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'channel_types.dart';
import 'keyframe.dart';

// AnimationTrack<V> contains zero or more keyframes for a given channel.
// The generic parameter [V] corresponds to the type of the values attached to
// the keyframes/channel (Vector3, Quaternion, etc).
//
abstract class AnimationTrack<V extends ChannelValueType> {
  // Adds a keyframe at [frameNumber] with the value [value].
  // If a keyframe already exists at [frameNumber], its value
  // is updated to [value].
  Future<Keyframe<V>> addOrUpdateKeyframe(int frameNumber, V value);

  // Removes the keyframe at [frameNumber]. If no keyframe exists at
  // [frameNumber], this is a noop.
  Future removeKeyframeAt(int frameNumber);

  // Returns the keyframe at [frame], or null if none exists.
  Keyframe<V>? keyframeAt(int frame);

  // Returns true if this track has a keyframe at [frame], false otherwise.
  bool hasKeyframeAt(int frame);

  // A map of frame numbers to keyframes.
  ValueListenable<Map<int, Keyframe<V>>> get keyframes;

  // A sorted list of all frames with associated keyframe values.
  // This is simply [keyframes.keys] sorted.
  List<int> get keyedFrames;

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
  V calculate(int frameNumber, {V? initial});

  List<String> get labels;

  //
  //
  //
  Future dispose();

  void setFromValues(dynamic values);
}

class AnimationTrackImpl<V extends ChannelValueType> extends AnimationTrack<V> {
  static final _logger = Logger("AnimationTrackImpl");

  @override
  final ValueNotifier<Map<int, Keyframe<V>>> keyframes =
      ValueNotifier<Map<int, Keyframe<V>>>({});

  @override
  final keyedFrames = [];

  final List<String> labels;

  AnimationTrackImpl(List<Keyframe<V>> keyframes, this.labels) {
    for (final kf in keyframes) {
      this.keyframes.value[kf.frameNumber.value] = kf;
      keyedFrames.add(kf.frameNumber.value);
    }
    keyedFrames.sort();
  }

  @override
  Future<Keyframe<V>> addOrUpdateKeyframe(int frameNumber, V value) async {
    final keyframe = KeyframeImpl<V>(frameNumber: frameNumber, value: value);

    await addKeyframe(keyframe);
    return keyframe;
  }

  Future addKeyframe(Keyframe<V> keyframe) async {
    await keyframes.value[keyframe.frameNumber.value]?.dispose();
    keyframes.value[keyframe.frameNumber.value] = keyframe;
    if (!keyedFrames.contains(keyframe.frameNumber.value)) {
      keyedFrames.add(keyframe.frameNumber.value);
      keyedFrames.sort();
    }
    keyframes.notifyListeners();
    _logger.info("Added keyframe at ${keyframe.frameNumber.value}");
  }

  @override
  Future removeKeyframeAt(int frameNumber) async {
    keyframes.value[frameNumber]?.dispose();
    keyframes.value.remove(frameNumber);
    keyframes.notifyListeners();
  }

  @override
  Keyframe<V>? keyframeAt(int frame) {
    return keyframes.value[frame];
  }

  @override
  Future dispose() async {
    for (final keyframe in keyframes.value.values) {
      keyframe.dispose();
    }
    keyframes.value.clear();
    keyframes.dispose();
  }

  @override
  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> keyframeJsonList = keyframes.value.values
        .map((keyframe) => keyframe.toJson())
        .toList();

    return {'keyframes': keyframeJsonList};
  }

  @override
  V calculate(int frameNumber, {V? initial}) {
    if (keyframes.value.isEmpty || keyedFrames.isEmpty) {
      return initial ?? ChannelValueType.zero<V>();
    }

    Keyframe? start;
    Keyframe? end;

    for (final keyedFrameNumber in keyedFrames) {
      if (keyedFrameNumber > frameNumber) {
        end = keyframes.value[keyedFrameNumber]!;
        break;
      }
      if (keyedFrameNumber <= frameNumber) {
        start = keyframes.value[keyedFrameNumber]!;
      }
    }

    if (start == null) {
      return keyframes.value[keyedFrames.first]!.value.value;
    }

    if (end == null) {
      return keyframes.value[keyedFrames.last]!.value.value;
    }

    var linearRatio =
        (frameNumber - start.frameNumber.value) /
        (end.frameNumber.value - start.frameNumber.value);

    return start.value.value.interpolate(end.value.value, linearRatio) as V;
  }

  @override
  bool hasKeyframeAt(int frame) {
    return keyframes.value[frame] != null;
  }

  @override
  void setFromValues(values) {
    V value = ChannelValueType.fromJson(values);
    
        // switch (V) {
        //       const (Vector3ChannelValueType) =>
        //         Vector3ChannelValueType.fromJson(values as List<double>),
        //       const (QuaternionChannelValueType) =>
        //         QuaternionChannelValueType.fromJson(json as List<double>),
        //   Type() => throw UnimplementedError(),
        //     }
        //     as V;
  }
}

extension on List<Keyframe> {
  Keyframe? firstWhereOrNull(bool Function(dynamic keyframe) param0) {
    return cast<Keyframe?>().firstWhere(param0, orElse: () => null);
  }
}
