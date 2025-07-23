import 'dart:math';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:logging/logging.dart';

class RandomObject {
  final String name;
  late Offset position;
  late double rotation;
  late double scaleX;
  late double scaleY;
  late Color color;

  late final positionTrack = AnimationTrackImpl(
    <Keyframe<Vector2ChannelValueType>>[],
    ["x", "y"],
    "position",
  );
  late final rotationTrack = AnimationTrackImpl(
    <Keyframe<ScalarChannelValueType>>[],
    ["rads"],
    "rotation",
  );
  late final scaleTrack = AnimationTrackImpl(
    <Keyframe<Vector2ChannelValueType>>[],
    ["x", "y"],
    "scale",
  );
  late final colorTrack = AnimationTrackImpl(
    <Keyframe<Vector4ChannelValueType>>[],
    ["r", "g", "b", "a"],
    "color",
  );

  late final AnimationTrackGroupImpl trackGroup;

  //
  ValueNotifier<bool> isVisible = ValueNotifier<bool>(true);

  RandomObject({
    required this.name,
    required this.position,
    required this.rotation,
    required this.scaleX,
    required this.scaleY,
    required this.color,
  }) {
    trackGroup = AnimationTrackGroupImpl([
      positionTrack,
      rotationTrack,
      scaleTrack,
      colorTrack,
    ], name);
  }

  void applyValue(AnimationTrack track, List<num> values) {
    if (track == positionTrack) {
      position = Offset(values[0].toDouble(), values[1].toDouble());
    } else if (track == scaleTrack) {
      scaleX = values[0].toDouble();
      scaleY = values[1].toDouble();
    }
  }
}

class ObjectHolder implements TrackController {
  final _rnd = Random();

  final _lookup = <AnimationTrackGroup, RandomObject>{};

  late List<RandomObject> objects;
  late List<AnimationTrackGroup> trackGroups;

  final void Function() onUpdate;

  RandomObject? get(AnimationTrackGroup group) {
    return _lookup[group];
  }

  ObjectHolder(int numObjects, this.onUpdate) {
    objects = List.generate(numObjects, (index) {
      final object = RandomObject(
        name: "object${index}",
        position: Offset(_rnd.nextDouble() * 100, _rnd.nextDouble() * 100),
        rotation: _rnd.nextDouble() * 2 * pi, // 0 to 2*pi radians
        scaleX: _rnd.nextDouble() * 1.5 + 0.5, // 0.5 to 2.0
        scaleY: _rnd.nextDouble() * 1.5 + 0.5, // 0.5 to 2.0
        color: Color.fromARGB(
          255,
          _rnd.nextInt(256),
          _rnd.nextInt(256),
          _rnd.nextInt(256),
        ),
      );
      _lookup[object.trackGroup] = object;
      return object;
    });

    trackGroups = objects.map((object) => object.trackGroup).toList();
  }

  @override
  U getCurrentValue<U extends ChannelValueType>(
    AnimationTrackGroup group,
    AnimationTrack<U> track,
  ) {
    final object = _lookup[group]!;
    if (track == object.colorTrack) {
      return Vector4ChannelValueType(
            Vector4(
              object.color.r,
              object.color.g,
              object.color.b,
              object.color.r,
            ),
          )
          as U;
    }
    if (track == object.positionTrack) {
      return Vector2ChannelValueType(
            Vector2(object.position.dx, object.position.dy),
          )
          as U;
    }
    if (track == object.scaleTrack) {
      return Vector2ChannelValueType(Vector2(object.scaleX, object.scaleY))
          as U;
    }
    if (track == object.rotationTrack) {
      return ScalarChannelValueType(object.rotation) as U;
    }

    throw Exception("Failed to find track");
  }

  @override
  void applyValue<U extends ChannelValueType>(
    AnimationTrackGroup group,
    AnimationTrack<U> track,
    List<num> values,
  ) {
    var object = _lookup[group];
    object!.applyValue(track, values);
    onUpdate.call();
  }
}
