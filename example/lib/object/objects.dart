import 'dart:math';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:logging/logging.dart';

class RandomObject {
  final String name;
  late Offset _position;
  late double _rotation;
  late double _scaleX;
  late double _scaleY;
  late Color _color;

  // Getters
  Offset get position => _position;
  double get rotation => _rotation;
  double get scaleX => _scaleX;
  double get scaleY => _scaleY;
  Color get color => _color;

  late final positionTrack = AnimationTrackImpl(
    keyframes: <Keyframe<Vector2ChannelValue>>[],
    labels: ["x", "y"],
    label: "position",
    defaultValues: [0.0, 0.0, 0.0]
  );
  late final rotationTrack = AnimationTrackImpl(
    keyframes: <Keyframe<ScalarChannelValue>>[],
    labels: ["rads"],
    label: "rotation",
    defaultValues: [0.0]
  );
  late final scaleTrack = AnimationTrackImpl(
    keyframes: <Keyframe<Vector2ChannelValue>>[],
    labels: ["x", "y"],
    label: "scale",
    defaultValues: [1.0, 1.0, 1.0]
  );
  late final colorTrack = AnimationTrackImpl(
    keyframes: <Keyframe<Vector4ChannelValue>>[],
    labels: ["r", "g", "b", "a"],
    label: "color",
    defaultValues: [1.0, 1.0, 1.0, 1.0]
  );

  late final AnimatableObjectImpl animatableObject;

  //
  ValueNotifier<bool> isVisible = ValueNotifier<bool>(true);
  final VoidCallback onUpdate;

  RandomObject({
    required this.onUpdate,
    required this.name,
    required Offset position,
    required double rotation,
    required double scaleX,
    required double scaleY,
    required Color color,
  }) : _position = position,
       _rotation = rotation,
       _scaleX = scaleX,
       _scaleY = scaleY,
       _color = color {
    animatableObject = AnimatableObjectImpl(
      tracks: [positionTrack, rotationTrack, scaleTrack, colorTrack],
      name: name,
    );

    setPosition(position);
    setRotation(rotation);
    setScaleX(scaleX);
    setScaleY(scaleY);
    setColor(color);
    positionTrack.value.addListener(_onPositionChanged);
    rotationTrack.value.addListener(_onRotationChanged);
    scaleTrack.value.addListener(_onScaleChanged);
    colorTrack.value.addListener(_onColorChanged);
  }
  void _onPositionChanged() {
    var values = positionTrack.value.value!.unwrap();
    if (values[0] != position.dx || values[1] != position.dy) {
      setPosition(
        Offset(values[0].toDouble(), values[1].toDouble()),
        notify: false,
      );
      onUpdate();
    }
  }

  void _onRotationChanged() {
    var values = rotationTrack.value.value!.unwrap();
    if (values[0] != rotation) {
      setRotation(values[0].toDouble(), notify: false);
      onUpdate();
    }
  }
  void _onScaleChanged() {
    var values = scaleTrack.value.value!.unwrap();
    if (values[0] != scaleX || values[1] != scaleY) {
      setScaleX(values[0].toDouble(), notify: false);
      setScaleY(values[1].toDouble(), notify: false);
      onUpdate();
    }
  }
  void _onColorChanged() {
    var values = colorTrack.value.value!.unwrap();
    final newColor = Color.fromARGB(
      (values[3] * 255).round().clamp(0, 255), // alpha
      (values[0] * 255).round().clamp(0, 255), // red
      (values[1] * 255).round().clamp(0, 255), // green
      (values[2] * 255).round().clamp(0, 255), // blue
    );
    if (newColor != color) {
      setColor(newColor, notify: false);
      onUpdate();
    }
  }

  // Setter methods
  void setPosition(Offset newPosition, {bool notify = true}) {
    _position = newPosition;
    if (notify) {
      positionTrack.setValue(
        Vector2ChannelValue(Vector2(position.dx, position.dy)),
      );
    }
  }

  void setRotation(double newRotation, {bool notify = true}) {
    _rotation = newRotation;
    if (notify) {
      rotationTrack.setValue(ScalarChannelValue(rotation));
    }
  }

  void setScaleX(double newScaleX, {bool notify = true}) {
    _scaleX = newScaleX;
    if (notify) {
      scaleTrack.setValue(Vector2ChannelValue(Vector2(_scaleX, _scaleY)));
    }
  }

  void setScaleY(double newScaleY, {bool notify = true}) {
    _scaleY = newScaleY;
    if (notify) {
      scaleTrack.setValue(Vector2ChannelValue(Vector2(_scaleX, _scaleY)));
    }
  }

  void setColor(Color newColor, {bool notify = true}) {
    _color = newColor;
    if (notify) {
      colorTrack.setValue(
        Vector4ChannelValue(Vector4(_color.r, _color.g, _color.b, _color.a)),
      );
    }
  }

  void setActualValue(AnimationTrack track, List<num> values) {
    if (track == positionTrack) {
      _position = Offset(values[0].toDouble(), values[1].toDouble());
    } else if (track == scaleTrack) {
      _scaleX = values[0].toDouble();
      _scaleY = values[1].toDouble();
    } else if (track == rotationTrack) {
      _rotation = values[0].toDouble();
    } else if (track == colorTrack) {
      _color = Color.fromARGB(
        (values[3] * 255).round().clamp(0, 255), // alpha
        (values[0] * 255).round().clamp(0, 255), // red
        (values[1] * 255).round().clamp(0, 255), // green
        (values[2] * 255).round().clamp(0, 255), // blue
      );
    }
  }
}

class ObjectHolder  {
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
      onUpdate: onUpdate,
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
    animatableObjects.add(object.animatableObject);
    _lookup[object.animatableObject] = object;

    // Notify timeline controller of new track object
    if (_timelineController != null) {
      _timelineController!.addObject(object.animatableObject);
    }

    onUpdate.call();
  }

  ObjectHolder(int numObjects, this.onUpdate) {
    objects = List.generate(numObjects, (index) {
      final object = RandomObject(
        onUpdate: onUpdate,
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
      _lookup[object.animatableObject] = object;
      return object;
    });

    animatableObjects = objects
        .map((object) => object.animatableObject)
        .toList();
  }

  // @override
  // U getCurrentValue<U extends ChannelValue>(
  //   AnimatableObject animatableObject,
  //   AnimationTrack<U> track,
  // ) {
  //   final object = _lookup[animatableObject]!;
  //   if (track == object.colorTrack) {
  //     return Vector4ChannelValue(
  //           Vector4(
  //             object._color.r,
  //             object._color.g,
  //             object._color.b,
  //             object._color.a,
  //           ),
  //         )
  //         as U;
  //   }
  //   if (track == object.positionTrack) {
  //     return Vector2ChannelValue(
  //           Vector2(object._position.dx, object._position.dy),
  //         )
  //         as U;
  //   }
  //   if (track == object.scaleTrack) {
  //     return Vector2ChannelValue(Vector2(object._scaleX, object._scaleY))
  //         as U;
  //   }
  //   if (track == object.rotationTrack) {
  //     return ScalarChannelValue(object._rotation) as U;
  //   }

  //   throw Exception("Failed to find track");
  // }

  // @override
  // void setActualValue<U extends ChannelValue>(
  //   AnimatableObject animatableObject,
  //   AnimationTrack<U> track,
  //   List<num> values,
  // ) {
  //   var object = _lookup[animatableObject];
  //   object!.setActualValue(track, values);
  //   onUpdate.call();
  // }
}
