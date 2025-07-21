import 'package:flutter/foundation.dart';
import 'package:flutter_keyframe_timeline/src/model/model.dart';

abstract class AnimationTrackGroup<V extends ChannelValueType> {
  ValueListenable<bool> get isVisible;
  void setVisible(bool visible);
  ValueListenable<bool> get isExpanded;
  void setExpanded(bool expanded);
  ValueListenable<bool> get isActive;
  void setActive(bool active);

  ValueListenable<String> get displayName;
  List<AnimationTrack<V>> get tracks;

  bool hasKeyframesAtFrame(int frame);

  Iterable<Keyframe<V>> getKeyframesAtFrame(int frame);
}

class AnimationTrackGroupImpl<V extends ChannelValueType>
    extends AnimationTrackGroup<V> {
  
  @override
  final List<AnimationTrack<V>> tracks;
    
  AnimationTrackGroupImpl(this.tracks, String displayName) {
    this.displayName.value = displayName;
  }

  @override
  ValueNotifier<String> displayName = ValueNotifier<String>("");

  @override
  Iterable<Keyframe<V>> getKeyframesAtFrame(int frame) {
    // TODO: implement getKeyframesAtFrame
    throw UnimplementedError();
  }

  @override
  bool hasKeyframesAtFrame(int frame) {
    // TODO: implement hasKeyframesAtFrame
    throw UnimplementedError();
  }

  @override
  void setVisible(bool visible) {
    this.isVisible.value = visible;
  }

  @override
  ValueNotifier<bool> isVisible = ValueNotifier<bool>(true);

  @override
  void setActive(bool active) {
    this.isActive.value = active;
  }

  @override
  ValueNotifier<bool> isActive = ValueNotifier<bool>(false);

  @override
  void setExpanded(bool expanded) {
    this.isExpanded.value = expanded;
  }

  @override
  ValueNotifier<bool> isExpanded = ValueNotifier<bool>(false);
}
