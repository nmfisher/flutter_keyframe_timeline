import 'package:flutter/foundation.dart';
import 'package:flutter_keyframe_timeline/src/model/model.dart';

abstract class AnimationTrackGroup {


  //
  ValueListenable<String> get displayName;

  //
  List<AnimationTrack> get tracks;

  //
  bool hasKeyframesAtFrame(int frame);

  //
  Iterable<Keyframe> getKeyframesAtFrame(int frame);
}

class AnimationTrackGroupImpl extends AnimationTrackGroup {
  @override
  final List<AnimationTrack> tracks;

  AnimationTrackGroupImpl(this.tracks, String name) {
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

  @override
  void setVisible(bool visible) {
    this.isVisible.value = visible;
  }

  @override
  ValueNotifier<bool> isVisible = ValueNotifier<bool>(true);
}
