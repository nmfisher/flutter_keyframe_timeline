import 'package:flutter/foundation.dart';
import 'channel_types.dart';

enum Interpolation { linear, constant }

//
//
//
abstract class Keyframe<V extends ChannelValueType> {
  
  // The frame number for this keyframe.
  ValueListenable<int> get frameNumber;

  // Update the frame number for this keyframe.
  Future setFrameNumber(int frameNumber);

  // The interpolation method for this keyframe. See [AnimationTrack.calculate]
  // for an explanation of how this is applied.
  ValueListenable<Interpolation> get interpolation;

  // The value of this keyframe.
  ValueListenable<V> get value;

  // Dispose of
  Future dispose();

  // Returns a JSON-serializable map for this keyframe.
  Map<String, dynamic> toJson();
}

class KeyframeImpl<V extends ChannelValueType> extends Keyframe<V>
    implements Comparable<Keyframe<V>> {
  
  @override
  final ValueNotifier<int> frameNumber = ValueNotifier<int>(0);

  @override
  final ValueNotifier<Interpolation> interpolation =
      ValueNotifier<Interpolation>(Interpolation.constant);

  @override
  late final ValueNotifier<V> value;

  KeyframeImpl({
    required int frameNumber,
    required V value,
    Interpolation interpolation = Interpolation.constant,
  }) : super() {
    this.value = ValueNotifier<V>(value);
    this.interpolation.value = interpolation;
    this.frameNumber.value = frameNumber;
  }

  static KeyframeImpl<QuaternionChannelValueType> quat(dynamic json) =>
      KeyframeImpl.fromJson<QuaternionChannelValueType>(json);

  static KeyframeImpl<Vector3ChannelValueType> vec3(dynamic json) =>
      KeyframeImpl.fromJson<Vector3ChannelValueType>(json);

  @override
  Future setFrameNumber(int frameNumber) async {
    this.frameNumber.value = frameNumber;
  }

  static KeyframeImpl<V> fromJson<V extends ChannelValueType>(
    Map<String, dynamic> json,
  ) {
    if (!json.containsKey('frame_number') || !json.containsKey('value')) {
      throw Exception('Missing required fields in JSON');
    }

    final frameNumber = json['frame_number'] as int;
    final List<dynamic> valueList = json['value'];
    final interpolation = json['interpolation'] != null
        ? Interpolation.values.firstWhere(
            (e) => e.toString() == json['interpolation'],
            orElse: () => Interpolation.constant,
          )
        : Interpolation.constant;

    final V value = ChannelValueType.fromJson<V>(
      valueList.map((v) => (v as num).toDouble()).toList(),
    );

    return KeyframeImpl<V>(
      frameNumber: frameNumber,
      value: value,
      interpolation: interpolation,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'frame_number': frameNumber.value,
      'value': value.value.toJson(),
      'interpolation': interpolation.value.toString(),
    };
  }

  @override
  Future dispose() async {
    interpolation.dispose();
    frameNumber.dispose();
    value.dispose();
  }

  @override
  int compareTo(Keyframe<V> other) {
    return frameNumber.value - other.frameNumber.value;
  }
}
