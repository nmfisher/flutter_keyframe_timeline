import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';
import 'package:vector_math/vector_math_64.dart';

class TimelineSerializer {
  static zero<V extends ChannelValueType>() {
    switch (V) {
      case const (ScalarChannelValueType):
        return ScalarChannelValueType(0.0);
      case const (Vector4ChannelValueType):
        return Vector4ChannelValueType(Vector4.zero());
      case const (Vector3ChannelValueType):
        return Vector3ChannelValueType(Vector3.zero());
      case const (Vector2ChannelValueType):
        return Vector2ChannelValueType(Vector2.zero());
      case const (QuaternionChannelValueType):
        return QuaternionChannelValueType(Quaternion.identity());
    }
  }

  static Keyframe parseKeyframe(Map<String, dynamic> json) {
    if (!json.containsKey('frame_number') ||
        !json.containsKey('value') ||
        !json.containsKey('value_type')) {
      throw Exception('Missing required fields in JSON');
    }

    final frameNumber = json['frame_number'] as int;
    final List<num> values = json['value']
        .map((v) => (v as num))
        .cast<num>()
        .toList();
    final interpolation = json['interpolation'] != null
        ? Interpolation.values.firstWhere(
            (e) => e.toString() == json['interpolation'],
            orElse: () => Interpolation.constant,
          )
        : Interpolation.constant;

    late ChannelValueType value;
    switch (json['value_type']) {
      case 'VEC4':
        value = Vector4ChannelValueType.fromUnwrapped(values);
      case 'VEC3':
        value = Vector3ChannelValueType.fromUnwrapped(values);
      case 'VEC2':
        value = Vector2ChannelValueType.fromUnwrapped(values);
      case 'SCALAR':
        value = ScalarChannelValueType(values[0] as double);
      case 'QUAT':
        value = QuaternionChannelValueType.fromUnwrapped(values);
    }

    return KeyframeImpl(
      frameNumber: frameNumber,
      value: value,
      interpolation: interpolation,
    );
  }

  V defaultZero<V extends ChannelValueType>() {
    switch (V) {
      case const (ScalarChannelValueType):
        return ScalarChannelValueType(0.0) as V;
      case const (Vector4ChannelValueType):
        return Vector4ChannelValueType(Vector4.zero()) as V;
      case const (Vector3ChannelValueType):
        return Vector3ChannelValueType(Vector3.zero()) as V;
      case const (Vector2ChannelValueType):
        return Vector2ChannelValueType(Vector2.zero()) as V;
      case const (QuaternionChannelValueType):
        return QuaternionChannelValueType(Quaternion.identity()) as V;
    }
    throw Exception("Unrecognized type $V");
  }

  static AnimationTrackGroup fromMap(
    Map<String, dynamic> group,
  ) {
    
    var name = group["name"] as String;
    
    var tracks = group["tracks"].map((track) {
      var keyframes = track["keyframes"]
          .map(parseKeyframe)
          .cast<Keyframe>()
          .toList();

      return AnimationTrackImpl(
        keyframes,
        track["labels"] as List<String>,
        track["label"],
      );
    }).toList();
    return AnimationTrackGroupImpl(tracks, name);
  }

  static Map<String, dynamic> toMap(AnimationTrackGroup group) {
    return {
      'tracks': group.tracks.map((track) {
        return {
          'label': track.label,
          'labels': track.labels,
          'keyframes': track.keyframes.value.values.map((keyframe) {
            return {
              'frame_number': keyframe.frameNumber.value,
              'value': keyframe.value.value.unwrap(),
              'value_type': keyframe.value.value.label,
              'interpolation': keyframe.interpolation.value.toString(),
            };
          }).toList(),
        };
      }).toList(),
    };
  }
}
