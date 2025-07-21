import 'package:flutter/foundation.dart';
import 'package:flutter_keyframe_timeline/src/model/src/animation_track.dart';
import 'package:flutter_keyframe_timeline/src/model/src/animation_track_group.dart';
import 'package:flutter_keyframe_timeline/src/model/src/channel_types.dart';
import 'package:flutter_keyframe_timeline/src/model/src/keyframe.dart';

abstract class TimelineController<V extends AnimationTrackGroup> {
  List<V> get trackGroups;

  ValueListenable<int> get pixelsPerFrame;

  ValueListenable<int> get currentFrame;
  ValueListenable<int> get maxFrames;

  void setCurrentFrame(int frame);

  void setZoomLevel(double level);
  void skipToStart();
  void skipToEnd();

  ValueListenable<Set<Keyframe>> get selected;

  U getCurrentValue<U extends ChannelValueType>(AnimationTrack<U> track);
}

class TimelineControllerImpl<V extends AnimationTrackGroup>
    extends TimelineController<V> {
  @override
  final List<V> trackGroups;

  TimelineControllerImpl(this.trackGroups);

  @override
  ValueNotifier<int> currentFrame = ValueNotifier<int>(0);

  @override
  ValueNotifier<int> maxFrames = ValueNotifier<int>(10000);

  @override
  ValueNotifier<int> pixelsPerFrame = ValueNotifier<int>(1);

  @override
  void setCurrentFrame(int frame) {
    this.currentFrame.value = frame;
  }

  @override
  ValueListenable<Iterable<V>> get expanded => throw UnimplementedError();

  @override
  void setExpanded(V asset, bool expanded) {
    throw UnimplementedError();
  }

  @override
  void setZoomLevel(double level) {
    // TODO: implement setZoomLevel
  }

  @override
  void skipToEnd() {
    // TODO: implement skipToEnd
  }

  @override
  void skipToStart() {
    // TODO: implement skipToStart
  }

  @override
  // TODO: implement selected
  ValueListenable<Set<Keyframe<ChannelValueType>>> get selected =>
      throw UnimplementedError();

  @override
  void setVisible(V trackGroup, bool visible) {
    // TODO: implement setVisible
  }
  
  @override
  U getCurrentValue<U extends ChannelValueType>(AnimationTrack<U> track) {
    // TODO: implement getCurrentValue
    throw UnimplementedError();
  }
}
