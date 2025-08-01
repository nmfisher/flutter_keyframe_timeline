import 'package:flutter/foundation.dart';
import 'package:flutter_keyframe_timeline/src/model/model.dart';

abstract class TimelineObject {
  //
  ValueListenable<String> get displayName;

  //
  List<AnimationTrack> get tracks;

  //
  bool hasKeyframesAtFrame(int frame);

  //
  Iterable<Keyframe> getKeyframesAtFrame(int frame);
}

class TimelineObjectImpl extends TimelineObject {
  @override
  final List<AnimationTrack> tracks;

  TimelineObjectImpl({required this.tracks, required String name}) {
    this.displayName.value = name;
  }
  @override
  ValueNotifier<String> displayName = ValueNotifier<String>("");

  @override
  Iterable<Keyframe> getKeyframesAtFrame(int frame) sync* {
    for (final track in tracks) {
      final kf = track.keyframeAt(frame);
      if (kf != null) {
        yield kf;
      }
    }
  }

  @override
  bool hasKeyframesAtFrame(int frame) {
    for (final track in tracks) {
      final kf = track.keyframeAt(frame);
      if (kf != null) {
        return true;
      }
    }
    return false;
  }
}
