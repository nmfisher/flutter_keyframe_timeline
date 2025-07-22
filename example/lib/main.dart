import 'dart:math';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:logging/logging.dart';

void main() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.loggerName} ${record.level.name}  ${record.message}');
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

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

class _TimelineController extends TimelineControllerImpl {
  final _lookup = <AnimationTrackGroup, RandomObject>{};

  final void Function() onUpdate;

  _TimelineController(List<RandomObject> objects, this.onUpdate)
    : super(objects.map((object) => object.trackGroup).toList()) {
    for (final object in objects) {
      _lookup[object.trackGroup] = object;
    }
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

class _MyHomePageState extends State<MyHomePage> {
  late List<RandomObject> _objects;
  late final TimelineController _controller;
  final _rnd = Random();

  final _numObjects = 3;

  @override
  void initState() {
    super.initState();
    _objects = List.generate(_numObjects, (index) {
      return RandomObject(
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
    });
    _controller = _TimelineController(_objects, () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: _objects.map((obj) {
                return Positioned(
                  left: obj.position.dx,
                  top: obj.position.dy,
                  child: Transform.rotate(
                    angle: obj.rotation,
                    child: Transform.scale(
                      scaleX: obj.scaleX,
                      scaleY: obj.scaleY,
                      child: Container(width: 50, height: 50, color: obj.color),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: TimelineWidget(controller: _controller)),
                Align(
                  alignment: Alignment.topLeft,
                  child: TimelineZoomControl(timelineController: _controller),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
