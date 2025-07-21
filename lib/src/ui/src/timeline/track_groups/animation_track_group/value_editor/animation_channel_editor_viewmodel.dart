import 'package:flutter/foundation.dart';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';
import 'package:flutter_keyframe_timeline/src/model/model.dart';
import 'package:vector_math/vector_math_64.dart';

abstract class AnimationChannelEditorViewModel {
  ValueListenable<bool> get hasKeyframeAtCurrentFrame;

  ValueListenable<ChannelValueType> get valueAtCurrentFrame;

  ///
  Future addKeyframeForCurrentFrame();

  ///
  Future deleteKeyframeForCurrentFrame();

  ///
  void setCurrentFrameValue(List<double> values);

  Future dispose();
}

class AnimationChannelEditorViewModelImpl
    extends AnimationChannelEditorViewModel {
  final Set<Keyframe> keyframes = {};

  @override
  final ValueNotifier<bool> hasKeyframeAtCurrentFrame = ValueNotifier<bool>(
    false,
  );

  @override
  late final ValueNotifier<ChannelValueType> valueAtCurrentFrame;

  final AnimationTrack track;
  final TimelineController controller;

  AnimationChannelEditorViewModelImpl(this.track, this.controller) {
    final currentValue = track.calculate(controller.currentFrame.value);
    valueAtCurrentFrame = ValueNotifier<ChannelValueType>(currentValue);
    track.keyframes.addListener(_onKeyframesUpdated);
    _onKeyframesUpdated();

    controller.currentFrame.addListener(_onFrameChange);
  }

  void _onFrameChange() {
    _updateHasKeyframeAtCurrentFrame();
  }

  void _updateHasKeyframeAtCurrentFrame() {
    valueAtCurrentFrame.value = track.calculate(controller.currentFrame.value);
    for (final kf in this.keyframes) {
      if (kf.frameNumber.value == controller.currentFrame.value) {
        this.hasKeyframeAtCurrentFrame.value = true;
      }
    }
    this.hasKeyframeAtCurrentFrame.value = false;
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
    
    track.addOrUpdateKeyframe(
          currentFrame,
          controller.getCurrentValue(track)

      );
    }
  

  @override
  void setCurrentFrameValue(List<double> values) {
    // var value = track.set
    // track.set(
    //       currentFrame,
    //       controller.getCurrentValue(track)

    //   );
    // }
    // switch (channel) {
    //   case AnimationChannel():
    //     model.setCurrentPosition(
    //       Vector3.fromFloat64List(Float64List.fromList(values)),
    //     );
    //   case ScaleChannel():
    //     model.setCurrentScale(
    //       Vector3.fromFloat64List(Float64List.fromList(values)),
    //     );
    //     break;
    //   case RotationChannel():
    //     model.setCurrentRotation(
    //       Quaternion.fromFloat64List(Float64List.fromList(values)),
    //     );
    //     break;
    // }
  }
}
