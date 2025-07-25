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

  late final AnimatableObjectImpl trackObject;

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
    trackObject = AnimatableObjectImpl([
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
    } else if (track == rotationTrack) {
      rotation = values[0].toDouble();
    } else if (track == colorTrack) {
      color = Color.fromARGB(
        (values[3] * 255).round().clamp(0, 255), // alpha
        (values[0] * 255).round().clamp(0, 255), // red
        (values[1] * 255).round().clamp(0, 255), // green
        (values[2] * 255).round().clamp(0, 255), // blue
      );
    }
  }
}

class ObjectHolder implements TrackController {
  final _rnd = Random();

  final _lookup = <AnimatableObject, RandomObject>{};

  late List<RandomObject> objects;
  late List<AnimatableObject> animatableObjects;

  final void Function() onUpdate;
  TimelineController? _timelineController;

  RandomObject? get(AnimatableObject object) {
    return _lookup[object];
  }

  void setTimelineController(TimelineController controller) {
    _timelineController = controller;
  }

  void removeObject(AnimatableObject animatableObject) {
    final object = _lookup[animatableObject];
    if (object != null) {
      objects.remove(object);
      animatableObjects.remove(object);
      _lookup.remove(object);
      onUpdate.call();
    }
  }

  void addNewObject() {
    final index = objects.length;
    final object = RandomObject(
      name: "object$index",
      position: Offset(_rnd.nextDouble() * 100, _rnd.nextDouble() * 100),
      rotation: _rnd.nextDouble() * 2 * pi,
      scaleX: _rnd.nextDouble() * 1.5 + 0.5,
      scaleY: _rnd.nextDouble() * 1.5 + 0.5,
      color: Color.fromARGB(
        255,
        _rnd.nextInt(256),
        _rnd.nextInt(256),
        _rnd.nextInt(256),
      ),
    );
    
    objects.add(object);
    animatableObjects.add(object.trackObject);
    _lookup[object.trackObject] = object;
    
    // Notify timeline controller of new track object
    if (_timelineController != null) {
      _timelineController!.addObject(object.trackObject);
    }
    
    onUpdate.call();
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
      _lookup[object.trackObject] = object;
      return object;
    });

    animatableObjects = objects.map((object) => object.trackObject).toList();
  }

  @override
  U getCurrentValue<U extends ChannelValueType>(
    AnimatableObject animatableObject,
    AnimationTrack<U> track,
  ) {
    final object = _lookup[animatableObject]!;
    if (track == object.colorTrack) {
      return Vector4ChannelValueType(
            Vector4(
              object.color.r,
              object.color.g,
              object.color.b,
              object.color.a,
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
    AnimatableObject animatableObject,
    AnimationTrack<U> track,
    List<num> values,
  ) {
    var object = _lookup[animatableObject];
    object!.applyValue(track, values);
    onUpdate.call();
  }
}
