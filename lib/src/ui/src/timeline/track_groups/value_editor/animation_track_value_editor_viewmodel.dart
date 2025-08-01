import 'package:flutter/foundation.dart';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';

abstract class AnimationTrackValueEditorViewModel<V extends ChannelValue> {
  // Returns true if this track has a keyframe at the current frame,
  // false otherwise.
  ValueListenable<bool> get hasKeyframeAtCurrentFrame;

  // Add an keyframe for this track at the current frame, with the current
  // actual value for the track.
  Future addKeyframeForCurrentFrame();

  ///
  Future deleteKeyframeForCurrentFrame();

  //
  ValueListenable<List<num>> get values;

  //
  void setActualValue(int channelIndex, double value);

  // Dispose this instance and destroy all ValueNotifiers and listeners.
  Future dispose();
}

class AnimationTrackValueEditorViewModelImpl<V extends ChannelValue>
    extends AnimationTrackValueEditorViewModel<V> {
  final Set<Keyframe> keyframes = {};

  @override
  final ValueNotifier<bool> hasKeyframeAtCurrentFrame = ValueNotifier<bool>(
    false,
  );

  final ValueNotifier<List<num>> values = ValueNotifier<List<num>>([]);

  final TimelineObject object;
  final AnimationTrack<V> track;
  final TimelineController controller;

  AnimationTrackValueEditorViewModelImpl(
      this.object, this.track, this.controller) {
    track.keyframes.addListener(_onKeyframesUpdated);
    _onKeyframesUpdated();
    track.value.addListener(_onActualValueChanged);
    controller.currentFrame.addListener(_onFrameChange);
    _onActualValueChanged();
  }

  void _onActualValueChanged() {
    values.value = track.value.value!.unwrap();
  }

  void _onFrameChange() {
    _updateHasKeyframeAtCurrentFrame();
    _onActualValueChanged();
  }

  void _updateHasKeyframeAtCurrentFrame() {
    var hasKeyframeAtCurrentFrame = false;
    for (final kf in this.keyframes) {
      if (kf.frameNumber.value == controller.currentFrame.value) {
        hasKeyframeAtCurrentFrame = true;
      }
    }
    this.hasKeyframeAtCurrentFrame.value = hasKeyframeAtCurrentFrame;
  }

  void _onKeyframesUpdated() {
    final newValue = track.keyframes.value.toSet();
    final removed = keyframes.difference(newValue);
    final added = newValue.difference(keyframes);
    for (final kf in removed) {
      kf.frameNumber.removeListener(_onKeyframeUpdated);
    }
    for (final kf in added) {
      kf.frameNumber.addListener(_onKeyframeUpdated);
    }
    keyframes.clear();
    keyframes.addAll(newValue);
    _updateHasKeyframeAtCurrentFrame();
  }

  @override
  Future dispose() async {
    track.value.removeListener(_onActualValueChanged);

    controller.currentFrame.removeListener(_onFrameChange);

    for (final kf in this.keyframes) {
      kf.frameNumber.removeListener(_onKeyframeUpdated);
    }

    track.keyframes.removeListener(_onKeyframesUpdated);
    hasKeyframeAtCurrentFrame.dispose();
  }

  void _onKeyframeUpdated() {
    _updateHasKeyframeAtCurrentFrame();
  }

  ///
  @override
  Future deleteKeyframeForCurrentFrame() async {
    final currentFrame = controller.currentFrame.value;
    track.removeKeyframeAt(currentFrame);
  }

  ///
  @override
  Future addKeyframeForCurrentFrame() async {
    final currentFrame = controller.currentFrame.value;
    track.addOrUpdateKeyframe(currentFrame, track.value.value!);
  }

  @override
  void setActualValue(int channelIndex, double value) {
    final newValue = track.value.value!.copyWith(channelIndex, value);
    track.setValue(newValue as V);
  }
}
