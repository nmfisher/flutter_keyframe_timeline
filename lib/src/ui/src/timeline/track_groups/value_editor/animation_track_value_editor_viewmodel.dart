import 'package:flutter/foundation.dart';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';
import 'package:flutter_keyframe_timeline/src/model/model.dart';
import 'package:vector_math/vector_math_64.dart';

abstract class AnimationTrackValueEditorViewModel<V extends ChannelValueType> {
  ValueListenable<bool> get hasKeyframeAtCurrentFrame;

  ///
  Future addKeyframeForCurrentFrame();

  ///
  Future deleteKeyframeForCurrentFrame();

  //
  void setCurrentFrameValue(List<double> values);

  //
  V getValue(int frame);

  //
  Future dispose();
}

class AnimationTrackValueEditorViewModelImpl<V extends ChannelValueType>
    extends AnimationTrackValueEditorViewModel<V> {
  final Set<Keyframe> keyframes = {};

  @override
  final ValueNotifier<bool> hasKeyframeAtCurrentFrame = ValueNotifier<bool>(
    false,
  );

  final AnimatableObject object;
  final AnimationTrack<V> track;
  final TimelineController controller;

  AnimationTrackValueEditorViewModelImpl(this.object, this.track, this.controller) {
    track.keyframes.addListener(_onKeyframesUpdated);
    _onKeyframesUpdated();

    controller.currentFrame.addListener(_onFrameChange);
  }

  void _onFrameChange() {
    _updateHasKeyframeAtCurrentFrame();
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
    final newValue = track.keyframes.value.values.toSet();
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
    var value = controller.getCurrentValue<V>(object, track);
    track.addOrUpdateKeyframe(currentFrame, value);
  }

  @override
  V getValue(int frame) {
    return controller.getCurrentValue<V>(object, track);
  }

  @override
  void setCurrentFrameValue(List<double> values) {
    controller.applyValue(object, track, values);
  }
}
