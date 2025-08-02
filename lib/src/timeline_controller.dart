import 'package:flutter/foundation.dart';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';
import 'package:timeline_dart/timeline_dart.dart' as dart;

abstract class TimelineController {
  //
  ValueNotifier<List<FlutterTimelineObject>> get animatableObjects;

  //
  void addObject(FlutterTimelineObject object);

  //
  void deleteObject(FlutterTimelineObject object);

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
  void select(Keyframe keyframe, KeyframeTrack track, {bool append = false});

  //
  void moveSelectedKeyframes(int frameDelta);

  //
  void addClipToObject(TimelineObject object, dynamic clip);

  //
  void addTransitionToObject(TimelineObject object, dynamic transition);

  //
  void clearSelectedKeyframes();

  //
  void deleteSelectedKeyframes();

  //
  ValueListenable<Set<TimelineObject>> get active;

  //
  void setActive(TimelineObject object, bool active, {bool append = false});

  //
  void updateActive(Set<TimelineObject> objects);

  //
  ValueListenable<Set<TimelineObject>> get expanded;

  //
  void setExpanded(TimelineObject object, bool expanded);

  // Dispose this instance and all associated ValueNotifiers.
  void dispose();

  factory TimelineController.create(List<FlutterTimelineObject> initial) {
    return TimelineControllerImpl._(initial);
  }
}

class TimelineControllerImpl implements TimelineController {
  @override
  final ValueNotifier<List<FlutterTimelineObject>> animatableObjects =
      ValueNotifier<List<FlutterTimelineObject>>([]);

  TimelineControllerImpl._(List<FlutterTimelineObject> initial) {
    animatableObjects.value.addAll(initial);
    this.currentFrame.addListener(_onCurrentFrameChanged);
  }

  void _onCurrentFrameChanged() {
    for (final object in animatableObjects.value) {
      final keyframeTracks = object.getTracks<KeyframeTrack>();
      for (final track in keyframeTracks) {
        if (track.keyframes.isNotEmpty) {
          var value = track.calculate(currentFrame.value);
          track.setValue(value);
        }
      }
    }
  }

  @override
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
    int last = 0;
    for (final kf in selected.value) {
      if (kf.frameNumber > last) {
        last = kf.frameNumber;
      }
    }
    if (last == 0) {
      setCurrentFrame(maxFrames.value);
    } else {
      setCurrentFrame(last);
    }
  }

  @override
  void skipToStart() {
    int first = maxFrames.value;
    for (final kf in selected.value) {
      if (kf.frameNumber < first) {
        first = kf.frameNumber;
      }
    }
    setCurrentFrame(first);
  }

  @override
  ValueNotifier<Set<Keyframe<ChannelValue>>> selected =
      ValueNotifier<Set<Keyframe<ChannelValue>>>({});

  final _selected = <Keyframe, KeyframeTrack>{};

  @override
  void select(Keyframe keyframe, KeyframeTrack track, {bool append = false}) {
    if (!append) {
      clearSelectedKeyframes(notify: false);
    }

    _initial.clear();

    selected.value.add(keyframe);
    _selected[keyframe] = track;
    selected.notifyListeners();
  }

  @override
  void clearSelectedKeyframes({bool notify = true}) {
    _initial.clear();

    selected.value.clear();
    _selected.clear();
    if (notify) {
      selected.notifyListeners();
    }
  }

  @override
  ValueNotifier<Set<TimelineObject>> active =
      ValueNotifier<Set<TimelineObject>>({});

  @override
  void setActive(TimelineObject object, bool active, {bool append = false}) {
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
  void updateActive(Set<TimelineObject> objects) {
    this.active.value.clear();
    this.active.value.addAll(objects);
    this.active.notifyListeners();
  }

  @override
  void addObject(FlutterTimelineObject object) {
    this.animatableObjects.value.add(object);
    this.animatableObjects.notifyListeners();
  }

  @override
  void deleteObject(TimelineObject object) {
    this.active.value.remove(object);
    this.selected.value.remove(object);
    this.animatableObjects.value.remove(object);
    this.animatableObjects.notifyListeners();
    this.selected.notifyListeners();
    this.active.notifyListeners();
  }

  //
  @override
  ValueNotifier<Set<TimelineObject>> expanded =
      ValueNotifier<Set<TimelineObject>>({});

  //
  @override
  void setExpanded(TimelineObject object, bool expanded) {
    if (expanded) {
      this.expanded.value.add(object);
    } else {
      this.expanded.value.remove(object);
    }
    this.expanded.notifyListeners();
  }

  //
  @override
  void deleteSelectedKeyframes() {
    for (final kf in selected.value) {
      var track = _selected[kf]!;
      track.removeKeyframeAt(kf.frameNumber);
    }
    clearSelectedKeyframes(notify: true);
    _initial.clear();
  }

  final _initial = <Keyframe, int>{};

  //
  @override
  void moveSelectedKeyframes(int frameDelta) {
    for (final kf in _selected.keys) {
      if (!_initial.containsKey(kf)) {
        _initial[kf] = kf.frameNumber;
      }
      var initial = _initial[kf]!;
      kf.setFrameNumber(initial + frameDelta);
    }
  }

  @override
  void addClipToObject(TimelineObject object, dynamic clip) {
    // Implementation would depend on having proper imports
    // For now, this is a placeholder for the new clip functionality
  }

  @override
  void addTransitionToObject(TimelineObject object, dynamic transition) {
    // Implementation would depend on having proper imports
    // For now, this is a placeholder for the new transition functionality
  }
}
