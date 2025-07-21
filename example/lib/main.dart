import 'dart:developer';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

void main() {
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final TimelineController _controller;

  @override
  void initState() {
    super.initState();
    const xyz = ["X", "Y", "Z"];
    const quat = ["X", "Y", "Z", "W"];
    var trackGroups = List<int>.generate(100, (i) => i)
        .expand((i) {
          return [
            AnimationTrackGroupImpl<Vector3ChannelValueType>([
              AnimationTrackImpl<Vector3ChannelValueType>([], xyz),
            ], "position$i"),
            AnimationTrackGroupImpl([
              AnimationTrackImpl<QuaternionChannelValueType>([], quat),
            ], "rotation$i"),
          ];
        })
        .cast<AnimationTrackGroup>()
        .toList();

    _controller = TimelineControllerImpl(trackGroups);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(child: TimelineWidget(controller: _controller)),
    );
  }
}
