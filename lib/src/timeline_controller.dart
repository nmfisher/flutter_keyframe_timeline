import 'package:flutter/foundation.dart';
import 'package:flutter_keyframe_timeline/src/model/src/animation_track.dart';
import 'package:flutter_keyframe_timeline/src/model/src/animation_track_group.dart';
import 'package:flutter_keyframe_timeline/src/model/src/channel_types.dart';
import 'package:flutter_keyframe_timeline/src/model/src/keyframe.dart';

abstract class TimelineController {
  //
  ValueNotifier<List<AnimationTrackGroup>> get trackGroups;

  //
  void addGroup(AnimationTrackGroup group);

  //
  void deleteGroup(AnimationTrackGroup group);

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
  void select(Keyframe keyframe, AnimationTrack track, {bool append = false});

  //
  void clearSelectedKeyframes();

  //
  void deleteSelectedKeyframes();

  //
  U getCurrentValue<U extends ChannelValueType>(
    AnimationTrackGroup target,
    AnimationTrack<U> track,
  );

  //
  void applyValue<U extends ChannelValueType>(
    AnimationTrackGroup group,
    AnimationTrack<U> track,
    List<num> values,
  );

  //
  ValueListenable<Set<AnimationTrackGroup>> get active;

  //
  void setActive(AnimationTrackGroup group, bool active, {bool append = false});

  //
  ValueListenable<Set<AnimationTrackGroup>> get expanded;

  //
  void setExpanded(AnimationTrackGroup group, bool expanded);
}

abstract class TrackController {
  //
  U getCurrentValue<U extends ChannelValueType>(
    AnimationTrackGroup target,
    AnimationTrack<U> track,
  );

  //
  void applyValue<U extends ChannelValueType>(
    AnimationTrackGroup group,
    AnimationTrack<U> track,
    List<num> values,
  );
}

class TimelineControllerImpl extends TimelineController {
  @override
  final ValueNotifier<List<AnimationTrackGroup>> trackGroups =
      ValueNotifier<List<AnimationTrackGroup>>([]);

  final TrackController trackController;

  TimelineControllerImpl(
    List<AnimationTrackGroup> initial,
    this.trackController,
  ) {
    trackGroups.value.addAll(initial);
    this.currentFrame.addListener(_onCurrentFrameChanged);
  }

  void _onCurrentFrameChanged() {
    for (final group in trackGroups.value) {
      for (final track in group.tracks) {
        if (track.keyframes.value.isNotEmpty) {
          var value = track.calculate(currentFrame.value);
          applyValue(group, track, value.unwrap());
        }
      }
    }
  }

  void dispose() {
    currentFrame.dispose();
    trackGroups.dispose();
    pixelsPerFrame.dispose();
    maxFrames.dispose();
  }

  @override
  ValueNotifier<int> currentFrame = ValueNotifier<int>(0);

  @override
  ValueNotifier<int> maxFrames = ValueNotifier<int>(10000);

  @override
  ValueNotifier<int> pixelsPerFrame = ValueNotifier<int>(5);

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
  ValueNotifier<Set<Keyframe<ChannelValueType>>> selected =
      ValueNotifier<Set<Keyframe<ChannelValueType>>>({});

  final _selected = <Keyframe, AnimationTrack>{};

  @override
  void select(Keyframe keyframe, AnimationTrack track, {bool append = false}) {
    if (!append) {
      clearSelectedKeyframes(notify: false);
    }

    selected.value.add(keyframe);
    _selected[keyframe] = track;
    selected.notifyListeners();
  }

  @override
  void clearSelectedKeyframes({bool notify = true}) {
    selected.value.clear();
    _selected.clear();
    if (notify) {
      selected.notifyListeners();
    }
  }

  ValueNotifier<Set<AnimationTrackGroup>> active =
      ValueNotifier<Set<AnimationTrackGroup>>({});

  @override
  void setActive(
    AnimationTrackGroup group,
    bool active, {
    bool append = false,
  }) {
    if (!active) {
      this.active.value.remove(group);
    } else {
      if (!append) {
        this.active.value.clear();
      }
      this.active.value.add(group);
    }
    this.active.notifyListeners();
  }

  @override
  void addGroup(AnimationTrackGroup group) {
    this.trackGroups.value.add(group);
    this.trackGroups.notifyListeners();
  }

  @override
  void deleteGroup(AnimationTrackGroup group) {
    this.active.value.remove(group);
    this.selected.value.remove(group);
    this.trackGroups.value.remove(group);
    this.trackGroups.notifyListeners();
    this.selected.notifyListeners();
    this.active.notifyListeners();
  }

  //
  @override
  ValueNotifier<Set<AnimationTrackGroup>> expanded =
      ValueNotifier<Set<AnimationTrackGroup>>({});

  //
  @override
  void setExpanded(AnimationTrackGroup group, bool expanded) {
    if (expanded) {
      this.expanded.value.add(group);
    } else {
      this.expanded.value.remove(group);
    }
    this.expanded.notifyListeners();
  }

  @override
  void applyValue<U extends ChannelValueType>(
    AnimationTrackGroup group,
    AnimationTrack<U> track,
    List<num> values,
  ) {
    trackController.applyValue(group, track, values);
  }

  @override
  U getCurrentValue<U extends ChannelValueType>(
    AnimationTrackGroup target,
    AnimationTrack<U> track,
  ) {
    return trackController.getCurrentValue<U>(target, track);
  }

  //
  @override
  void deleteSelectedKeyframes() {
    for (final kf in selected.value) {
      var track = _selected[kf]!;
      track.removeKeyframeAt(kf.frameNumber.value);
    }
    clearSelectedKeyframes(notify: true);
  }
}
