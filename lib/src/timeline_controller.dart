import 'package:flutter/foundation.dart';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';

abstract class TimelineController {
  //
  ValueNotifier<List<AnimatableObject>> get animatableObjects;

  //
  void addObject(AnimatableObject object);

  //
  void deleteObject(AnimatableObject object);

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
    AnimatableObject object,
    AnimationTrack<U> track,
    List<num> values,
  );

  //
  ValueListenable<Set<AnimatableObject>> get active;

  //
  void setActive(AnimatableObject object, bool active, {bool append = false});

  //
  ValueListenable<Set<AnimatableObject>> get expanded;

  //
  void setExpanded(AnimatableObject object, bool expanded);

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
    AnimatableObject object,
    AnimationTrack<U> track,
    List<num> values,
  );
}

class TimelineControllerImpl extends TimelineController {
  @override
  final ValueNotifier<List<AnimatableObject>> animatableObjects =
      ValueNotifier<List<AnimatableObject>>([]);

  final TrackController trackController;

  TimelineControllerImpl(List<AnimatableObject> initial, this.trackController) {
    animatableObjects.value.addAll(initial);
    this.currentFrame.addListener(_onCurrentFrameChanged);
  }

  void _onCurrentFrameChanged() {
    for (final object in animatableObjects.value) {
      for (final track in object.tracks) {
        if (track.keyframes.value.isNotEmpty) {
          var value = track.calculate(currentFrame.value);
          applyValue(object, track, value.unwrap());
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
  void setActive(AnimatableObject object, bool active, {bool append = false}) {
    if (!active) {
      this.active.value.remove(object);
    } else {
      if (!append) {
        this.active.value.clear();
      }
      this.active.value.add(object);
    }
    this.active.notifyListeners();
  }

  @override
  void addObject(AnimatableObject object) {
    this.animatableObjects.value.add(object);
    this.animatableObjects.notifyListeners();
  }

  @override
  void deleteObject(AnimatableObject object) {
    this.active.value.remove(object);
    this.selected.value.remove(object);
    this.animatableObjects.value.remove(object);
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
  void setExpanded(AnimatableObject object, bool expanded) {
    if (expanded) {
      this.expanded.value.add(object);
    } else {
      this.expanded.value.remove(object);
    }
    this.expanded.notifyListeners();
  }

  @override
  void applyValue<U extends ChannelValueType>(
    AnimatableObject object,
    AnimationTrack<U> track,
    List<num> values,
  ) {
    trackController.applyValue(object, track, values);
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
