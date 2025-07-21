import 'package:flutter/foundation.dart';
import 'package:flutter_keyframe_timeline/src/model/src/animation_track.dart';
import 'package:flutter_keyframe_timeline/src/model/src/animation_track_group.dart';
import 'package:flutter_keyframe_timeline/src/model/src/channel_types.dart';
import 'package:flutter_keyframe_timeline/src/model/src/keyframe.dart';

enum SelectionMode { append, replace }

abstract class TimelineController<V extends AnimationTrackGroup> {
  //
  ValueNotifier<List<V>> get trackGroups;

  //
  void addGroup(V group);

  //
  void deleteGroup(V group);

  //
  ValueListenable<int> get pixelsPerFrame;

  //
  ValueListenable<int> get currentFrame;

  //
  ValueListenable<int> get maxFrames;

  //
  void setCurrentFrame(int frame);

  //
  void setZoomLevel(double level);

  //
  void skipToStart();

  //
  void skipToEnd();

  //
  ValueListenable<Set<Keyframe>> get selected;

  //
  U getCurrentValue<U extends ChannelValueType>(AnimationTrack<U> track);

  //
  ValueListenable<Set<V>> get active;

  //
  void setActive(V group, bool active);

  //
  void setSelectionMode(SelectionMode mode);
}

abstract class TimelineControllerImpl<V extends AnimationTrackGroup>
    extends TimelineController<V> {
  
  @override
  final ValueNotifier<List<V>> trackGroups = ValueNotifier<List<V>>([]);
  

  TimelineControllerImpl(List<V> initial) {
    trackGroups.value.addAll(initial);
  }

  @override
  ValueNotifier<int> currentFrame = ValueNotifier<int>(0);

  @override
  ValueNotifier<int> maxFrames = ValueNotifier<int>(10000);

  @override
  ValueNotifier<int> pixelsPerFrame = ValueNotifier<int>(75);

  @override
  void setCurrentFrame(int frame) {
    this.currentFrame.value = frame;
  }

  @override
  void setZoomLevel(double level) {
    // Clamp the input level between 0 and 1
    final clampedLevel = level.clamp(0.0, 1.0);

    // Map the 0-1 range to 1-10 range for pixels per frame
    // Using round() to ensure we get an integer
    final newPixelsPerFrame = ((clampedLevel * 9) + 1).round();

    pixelsPerFrame.value = newPixelsPerFrame;
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


  var _mode = SelectionMode.replace;
  void setSelectionMode(SelectionMode mode) {
    this._mode = mode;
  }

  ValueNotifier<Set<V>> active = ValueNotifier<Set<V>>({});

  @override
  void setActive(V group, bool active) {
    if (!active) {
      this.active.value.remove(group);
    } else {
      if (_mode != SelectionMode.append) {
        this.active.value.clear();
      }
      this.active.value.add(group);
    }
    this.active.notifyListeners();
  }

  @override
  void addGroup(V group) {
    this.active.value.add(group);
    this.active.notifyListeners();
  }

  @override
  void deleteGroup(V group) {
    this.active.value.remove(group);
    this.active.notifyListeners();
  }
}
