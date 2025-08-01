import 'package:flutter/foundation.dart';
import 'package:flutter_keyframe_timeline/src/model/model.dart';

abstract class TimelineObject {
  //
  ValueListenable<String> get displayName;

  //
  List<BaseTrack> get tracks;

  //
  List<V> getTracks<V extends BaseTrack>();

  //
  bool hasKeyframesAtFrame(int frame);

  //
  Iterable<Keyframe> getKeyframesAtFrame(int frame);
}

class TimelineObjectImpl extends TimelineObject {
  
  @override
  final List<BaseTrack> tracks;
  
  @override
  ValueNotifier<String> displayName = ValueNotifier<String>("");

  TimelineObjectImpl({
    required this.tracks, 
    required String name
  }) {
    this.displayName.value = name;
  }

  @override
  List<V> getTracks<V extends BaseTrack>() {
    return tracks.whereType<V>().toList();
  }

  @override
  Iterable<Keyframe> getKeyframesAtFrame(int frame) sync* {
    for (final track in tracks) {
      if (track is KeyframeTrack) {
        final kf = track.keyframeAt(frame);
        if (kf != null) {
          yield kf;
        }
      }
    }
  }

  @override
  bool hasKeyframesAtFrame(int frame) {
    for (final track in tracks) {
      if (track is KeyframeTrack) {
        final kf = track.keyframeAt(frame);
        if (kf != null) {
          return true;
        }
      }
    }
    return false;
  }
}
