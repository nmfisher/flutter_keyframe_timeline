import 'package:flutter/foundation.dart';
import 'package:flutter_keyframe_timeline/src/model/src/animation_track.dart';
import 'package:flutter_keyframe_timeline/src/model/src/animation_track_group.dart';
import 'package:flutter_keyframe_timeline/src/model/src/channel_types.dart';
import 'package:flutter_keyframe_timeline/src/model/src/keyframe.dart';

abstract class TimelineController {
  //
  ValueNotifier<List<AnimatableObject>> get animatableObjects;

  //
  void resetGroups(List<AnimatableObject> groups);

  //
  void addGroup(AnimatableObject group);

  //
  void deleteGroup(AnimatableObject group);

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
    AnimatableObject target,
    AnimationTrack<U> track,
  );

  //
  void applyValue<U extends ChannelValueType>(
    AnimatableObject group,
    AnimationTrack<U> track,
    List<num> values,
  );

  //
  ValueListenable<Set<AnimatableObject>> get active;

  //
  void setActive(AnimatableObject group, bool active, {bool append = false});

  //
  ValueListenable<Set<AnimatableObject>> get expanded;

  //
  void setExpanded(AnimatableObject group, bool expanded);

  // Dispose this instance and all associated ValueNotifiers.
  void dispose();
}

abstract class TrackController {
  //
  U getCurrentValue<U extends ChannelValueType>(
    AnimatableObject target,
    AnimationTrack<U> track,
  );

  //
  void applyValue<U extends ChannelValueType>(
    AnimatableObject group,
    AnimationTrack<U> track,
    List<num> values,
  );
}

class TimelineControllerImpl extends TimelineController {
  @override
  final ValueNotifier<List<AnimatableObject>> animatableObjects =
      ValueNotifier<List<AnimatableObject>>([]);

  final TrackController trackController;

  TimelineControllerImpl(
    List<AnimatableObject> initial,
    this.trackController,
  ) {
    animatableObjects.value.addAll(initial);
    this.currentFrame.addListener(_onCurrentFrameChanged);
  }

  void _onCurrentFrameChanged() {
    for (final group in animatableObjects.value) {
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
    animatableObjects.dispose();
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

  ValueNotifier<Set<AnimatableObject>> active =
      ValueNotifier<Set<AnimatableObject>>({});

  @override
  void setActive(
    AnimatableObject group,
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
  void resetGroups(List<AnimatableObject> groups) {
    this.animatableObjects.value.clear();
    this.animatableObjects.value.addAll(groups);
    this.animatableObjects.notifyListeners();
  }

  @override
  void addGroup(AnimatableObject group) {
    this.animatableObjects.value.add(group);
    this.animatableObjects.notifyListeners();
  }

  @override
  void deleteGroup(AnimatableObject group) {
    this.active.value.remove(group);
    this.selected.value.remove(group);
    this.animatableObjects.value.remove(group);
    this.animatableObjects.notifyListeners();
    this.selected.notifyListeners();
    this.active.notifyListeners();
  }

  //
  @override
  ValueNotifier<Set<AnimatableObject>> expanded =
      ValueNotifier<Set<AnimatableObject>>({});

  //
  @override
  void setExpanded(AnimatableObject group, bool expanded) {
    if (expanded) {
      this.expanded.value.add(group);
    } else {
      this.expanded.value.remove(group);
    }
    this.expanded.notifyListeners();
  }

  @override
  void applyValue<U extends ChannelValueType>(
    AnimatableObject group,
    AnimationTrack<U> track,
    List<num> values,
  ) {
    trackController.applyValue(group, track, values);
  }

  @override
  U getCurrentValue<U extends ChannelValueType>(
    AnimatableObject target,
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
