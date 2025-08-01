import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';

class TimelineSerializer {
  static Keyframe<V> parseKeyframe<V extends ChannelValue>(
      Map<String, dynamic> json, ChannelValueFactory factory) {
    if (!json.containsKey('frame_number') ||
        !json.containsKey('value')) {
      throw Exception('Missing required fields in JSON');
    }

    final frameNumber = json['frame_number'] as int;
    final List<num> values =
        json['value'].map((v) => (v as num)).cast<num>().toList();
    final interpolation = json['interpolation'] != null
        ? Interpolation.values.firstWhere(
            (e) => e.toString() == json['interpolation'],
            orElse: () => Interpolation.constant,
          )
        : Interpolation.constant;

    late V value = factory.create<V>(values) as V;

    return KeyframeImpl<V>(
      frameNumber: frameNumber,
      value: value,
      interpolation: interpolation,
    );
  }

  static AnimationTrack<V> parseTrack<V extends ChannelValue>(Map<String, dynamic> track, ChannelValueFactory factory, List<num> defaultValues) {

    var rawKeyframes = track["keyframes"] as List;

    final keyframes = <Keyframe<V>>[];

    for (final raw in rawKeyframes) {
      final kf = parseKeyframe<V>(raw, factory);
      keyframes.add(kf);
    }


    return AnimationTrackImpl<V>(
      defaultValues:defaultValues,
      keyframes: keyframes,
      labels: track["labels"].cast<String>(),
      label: track["label"],
    );
  }

  static TimelineObject fromMap(Map<String, dynamic> object,
      {ChannelValueFactory factory = const DefaultChannelValueFactory()}) {
    var name = object["name"] as String;

    var tracks = object["tracks"]
        .map((track) {
          

          return switch (track['value_type']) {
            'VEC4' => parseTrack<Vector4ChannelValue>(track, factory, [0, 0, 0, 0]),
            'VEC3' => parseTrack<Vector3ChannelValue>(track, factory, [0, 0, 0]),
            'VEC2' => parseTrack<Vector2ChannelValue>(track, factory, [0, 0]),
            'QUAT' => parseTrack<QuaternionChannelValue>(track, factory,[0, 0, 0, 1]),
            'SCALAR' => parseTrack<ScalarChannelValue>(track, factory, [0]),
            _ =>
              throw Exception("Unrecognized value type ${track['value_type']}")
          };
        })
        .cast<AnimationTrack>()
        .toList();
    return TimelineObjectImpl(tracks: tracks, name: name);
  }

  static Type getType<T>() {
    return T;
  }

  static String getTypeLabel(AnimationTrack track) {
    final trackType = track.getType();

    if (trackType == getType<Vector2ChannelValue>()) {
      return "VEC2";
    }

    if (trackType == getType<Vector3ChannelValue>()) {
      return "VEC3";
    }

    if (trackType == getType<Vector4ChannelValue>()) {
      return "VEC4";
    }

    if (trackType == getType<QuaternionChannelValue>()) {
      return "QUAT";
    }

    if (trackType == getType<ScalarChannelValue>()) {
      return "SCALAR";
    }

    throw Exception();
  }

  static Map<String, dynamic> toMap(TimelineObject object) {
    return {
      'name': object.displayName.value,
      'tracks': object.tracks.map((track) {
        return {
          'label': track.label,
          'labels': track.labels,
          'value_type': getTypeLabel(track),
          'keyframes': track.keyframes.value.map((keyframe) {
            return {
              'frame_number': keyframe.frameNumber.value,
              'value': keyframe.value.value.unwrap(),
              'interpolation': keyframe.interpolation.value.toString(),
            };
          }).toList(),
        };
      }).toList(),
    };
  }
}
