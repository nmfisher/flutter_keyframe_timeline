import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyframe_timeline_example/object/objects.dart';
import 'package:flutter_keyframe_timeline_example/object_display_widget.dart';
import 'package:flutter_keyframe_timeline_example/track_object_visibility_widget.dart';
import 'package:flutter_keyframe_timeline_example/timeline_skip_control.dart';
import 'package:logging/logging.dart';
import 'package:mix/mix.dart';

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
    _controller = TimelineController.create(_objectHolder.animatableObjects);
    _objectHolder.setTimelineController(_controller);
    final map = TimelineSerializer.toMap(_objectHolder.animatableObjects.first);
    final foo = TimelineSerializer.fromMap(map);
    print(foo);
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

                    trackObjectExtraWidgetBuilder:
                        (
                          BuildContext context,
                          TimelineObject animatableObject,
                          bool trackObjectIsActive,
                          bool trackObjectIsExpanded,
                        ) {
                          final object = _objectHolder.get(animatableObject);
                          // Only show widget for RandomObject (VideoObject doesn't have visibility controls)
                          if (object is! RandomObject) {
                            return SizedBox.shrink();
                          }
                          return TrackObjectVisibilityWidget(
                            object: object,
                            isActive: trackObjectIsActive,
                            isExpanded: trackObjectIsExpanded,
                            onRemove: () {
                              _controller.deleteObject(animatableObject);
                              _objectHolder.removeObject(animatableObject);
                            },
                          );
                        },

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
                    backgroundStyle: TimelineBackgroundStyle(
                      majorTickColor: Colors.grey.shade500,
                      minorTickColor: Colors.grey.shade300,
                      textColor: Colors.grey.shade700,
                      majorTickInterval: 10,
                      minorTickInterval: 1,
                    ),
                    trackObjectNameStyle: TrackObjectNameStyle(
                      iconData: Icons.folder,
                      textColor: Colors.blue.shade800,
                      iconColor: Colors.blue.shade600,
                      borderColor: Colors.blue.shade200,
                    ),
                    channelValueEditorStyle: ChannelValueEditorStyle(
                      textFieldFontColor: Colors.green.shade700,
                      textFieldFontSize: 12.0,
                      labelBuilder: (label) {
                        return StyledText(
                          label,
                          style: Style($text.fontSize(10.0)),
                        );
                      },
                      width: 65.0,
                      backgroundColor: Colors.green.shade50,
                      borderColor: Colors.green.shade400,
                      enabledBorderColor: Colors.green.shade300,
                      focusedBorderColor: Colors.green.shade600,
                      errorBorderColor: Colors.red.shade400,
                    ),
                    channelValueEditorContainerBuilder:
                        (
                          context,
                          textField,
                          controller,
                          dimensionLabel,
                          dimensionIndex,
                        ) {
                          return Container(
                            width: 120,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue.shade300),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  dimensionLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                                SizedBox(width: 3),
                                Expanded(child: textField),
                              ],
                            ),
                          );
                        },
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Row(
                    children: [
                      TimelineZoomControl(timelineController: _controller),
                      SizedBox(width: 8),
                      TimelineSkipControl(timelineController: _controller),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _objectHolder.addNewVideoObject();
                        },
                        child: Text('Add Video'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
