import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyframe_timeline_example/object/objects.dart';
import 'package:flutter_keyframe_timeline_example/object_display_widget.dart';
import 'package:flutter_keyframe_timeline_example/track_visibility_widget.dart';
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

class _MyHomePageState extends State<MyHomePage> {
  late final ObjectHolder _objectHolder;

  late final TimelineController _controller;

  final _numObjects = 5;

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
    _objectHolder.setTimelineController(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ObjectDisplayWidget(
              objectHolder: _objectHolder,
              timelineController: _controller,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: TimelineWidget(
                    controller: _controller,
                    trackGroupExtraWidgetBuilder:
                        (
                          BuildContext context,
                          AnimationTrackGroup group,
                          bool trackGroupIsActive,
                          bool trackGroupIsExpanded,
                        ) {
                          final object = _objectHolder.get(group);
                          return TrackGroupVisibilityWidget(
                            object: object!,
                            isActive: trackGroupIsActive,
                            isExpanded: trackGroupIsExpanded,
                            onRemove: () {
                              _controller.deleteGroup(group);
                              _objectHolder.removeObject(group);
                            },
                          );
                        },
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
                                              color: Colors.blue.withValues(
                                                alpha: 0.6,
                                              ),
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
