import 'package:flutter/foundation.dart';
import 'package:flutter_keyframe_timeline/src/model/model.dart';

abstract class AnimatableObject {

  //
  ValueListenable<String> get displayName;

  //
  List<AnimationTrack> get tracks;

  //
  bool hasKeyframesAtFrame(int frame);

  //
  Iterable<Keyframe> getKeyframesAtFrame(int frame);
}

class AnimatableObjectImpl extends AnimatableObject {
  @override
  final List<AnimationTrack> tracks;

  AnimatableObjectImpl(this.tracks, String name) {
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
