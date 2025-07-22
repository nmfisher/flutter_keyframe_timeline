import 'dart:math';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class ObjectHolder implements TrackController {
  final _rnd = Random();

  final _lookup = <AnimationTrackGroup, RandomObject>{};

  late List<RandomObject> _objects;
  late List<AnimationTrackGroup> trackGroups;

  final void Function() onUpdate;

  ObjectHolder(int numObjects, this.onUpdate) {
    _objects = List.generate(numObjects, (index) {
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

    trackGroups = _objects.map((object) => object.trackGroup).toList();
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
  late final ObjectHolder _objectHolder;

  late final TimelineController _controller;

  final _numObjects = 3;
  
  RandomObject? _selectedObject;

  @override
  void initState() {
    super.initState();
    _objectHolder = ObjectHolder(_numObjects, () {
      setState(() {});
    });
    _controller = TimelineControllerImpl(
      _objectHolder.trackGroups,
      _objectHolder,
    );
    
    // Listen to active track group changes and sync canvas selection
    _controller.active.addListener(() {
      final activeGroups = _controller.active.value;
      if (activeGroups.isEmpty) {
        setState(() {
          _selectedObject = null;
        });
      } else {
        // Find the object corresponding to the first active track group
        final activeGroup = activeGroups.first;
        final activeObject = _objectHolder._objects.firstWhere(
          (obj) => obj.trackGroup == activeGroup,
          orElse: () => _objectHolder._objects.first,
        );
        setState(() {
          _selectedObject = activeObject;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.active.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                ..._objectHolder._objects.map((obj) {
                final isSelected = _selectedObject == obj;
                return Positioned(
                  left: obj.position.dx,
                  top: obj.position.dy,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedObject = obj;
                      });
                      _controller.setActive(obj.trackGroup, true);
                    },
                    onPanUpdate: (details) {
                      if (_selectedObject == obj) {
                        final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
                        
                        setState(() {
                          if (isShiftPressed) {
                            // Scale mode: use vertical drag to scale uniformly
                            final scaleChange = -details.delta.dy * 0.01; // Negative for intuitive up=bigger
                            obj.scaleX = (obj.scaleX + scaleChange).clamp(0.1, 5.0);
                            obj.scaleY = (obj.scaleY + scaleChange).clamp(0.1, 5.0);
                          } else {
                            // Move mode: update position
                            obj.position = Offset(
                              obj.position.dx + details.delta.dx,
                              obj.position.dy + details.delta.dy,
                            );
                          }
                        });
                        _objectHolder.onUpdate.call();
                      }
                    },
                    child: Transform.rotate(
                      angle: obj.rotation,
                      child: Transform.scale(
                        scaleX: obj.scaleX,
                        scaleY: obj.scaleY,
                        child: Container(
                          width: 50, 
                          height: 50, 
                          decoration: BoxDecoration(
                            color: obj.color,
                            border: isSelected ? Border.all(
                              color: Colors.red, 
                              width: 3,
                            ) : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Mouse Controls:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Click to select object',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          '• Drag to move selected object',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          '• Shift+Drag to scale selected object',
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Selection Sync:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '• Selecting in timeline selects object',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          '• Selecting object selects timeline',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: TimelineWidget(
                    controller: _controller,
                    style: TimelineStyle(
                      keyframeIconBuilder:
                          (context, isSelected, isHovered, frameNumber) {
                            return Transform.translate(
                              offset: const Offset(
                                -11,
                                0.0,
                              ), // Center the 16px icon
                              child: Container(
                                padding: EdgeInsets.all(4),
                                child: Container(
                                  width: 15,
                                  height: 15,
                                  decoration: BoxDecoration(
                                    boxShadow: isSelected || isHovered
                                        ? [
                                            BoxShadow(
                                              color: Colors.blue.withValues(alpha: 0.6),
                                              spreadRadius: isSelected ? 3 : 2,
                                              blurRadius: isSelected ? 6 : 4,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Transform.rotate(
                                    angle:
                                        0.785398, // 45 degrees in radians (pi/4)
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                      // keyframeToggleIconBuilder: (context, hasKeyframeAtCurrentFrame, onPressed) {
                      //   return IconButton(
                      //     onPressed: onPressed,
                      //     icon: Container(
                      //       width: 18,
                      //       height: 18,
                      //       decoration: BoxDecoration(
                      //         shape: BoxShape.circle,
                      //         color: hasKeyframeAtCurrentFrame ? Colors.green : Colors.red.withValues(alpha: 0.3),
                      //         border: Border.all(
                      //           color: hasKeyframeAtCurrentFrame ? Colors.green.shade800 : Colors.red,
                      //           width: 2,
                      //         ),
                      //       ),
                      //       child: Icon(
                      //         hasKeyframeAtCurrentFrame ? Icons.check : Icons.add,
                      //         color: hasKeyframeAtCurrentFrame ? Colors.white : Colors.red,
                      //         size: 12,
                      //       ),
                      //     ),
                      //     padding: EdgeInsets.zero,
                      //     constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                      //   );
                      // },
                      frameDragHandleStyle: FrameDragHandleStyle(
                        backgroundColor: Color(0xFF333333),
                        width: 50.0,
                        height: 30.0,
                        textBuilder: (context, text) => Text(
                          text,
                          style: TextStyle(
                            color: Color(0xFFEEEEEE),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
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
