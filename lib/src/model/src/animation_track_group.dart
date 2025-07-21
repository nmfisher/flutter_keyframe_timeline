import 'package:flutter/foundation.dart';
import 'package:flutter_keyframe_timeline/src/model/model.dart';

abstract class AnimationTrackGroup {
  ValueListenable<bool> get isVisible;
  void setVisible(bool visible);
  // ValueListenable<bool> get isExpanded;
  // void setExpanded(bool expanded);

  ValueListenable<String> get displayName;
  List<AnimationTrack> get tracks;

  bool hasKeyframesAtFrame(int frame);

  Iterable<Keyframe> getKeyframesAtFrame(int frame);
}

abstract class AnimationTrackGroupImpl extends AnimationTrackGroup {
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
