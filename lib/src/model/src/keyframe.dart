import 'package:flutter/foundation.dart';
import 'channel_types.dart';

enum Interpolation { linear, constant }

//
//
abstract class Keyframe<V extends ChannelValue> {
  // The frame number for this keyframe.
  ValueListenable<int> get frameNumber;

  // Update the frame number for this keyframe.
  Future setFrameNumber(int frameNumber);

  // The interpolation method for this keyframe. See [AnimationTrack.calculate]
  // for an explanation of how this is applied.
  ValueListenable<Interpolation> get interpolation;

  // The value of this keyframe.
  ValueListenable<V> get value;

  // Dispose this object and all value notifiers
  Future dispose();

  V interpolate(V next, double linearRatio);
}

class KeyframeImpl<V extends ChannelValue> extends Keyframe<V>
    implements Comparable<Keyframe<V>> {
  @override
  final ValueNotifier<int> frameNumber = ValueNotifier<int>(0);

  @override
  final ValueNotifier<Interpolation> interpolation =
      ValueNotifier<Interpolation>(Interpolation.linear);

  @override
  late final ValueNotifier<V> value;

  KeyframeImpl({
    required int frameNumber,
    required V value,
    Interpolation interpolation = Interpolation.linear,
  }) : super() {
    this.value = ValueNotifier<V>(value);
    this.interpolation.value = interpolation;
    this.frameNumber.value = frameNumber;
  }

  @override
  Future setFrameNumber(int frameNumber) async {
    this.frameNumber.value = frameNumber;
  }

  @override
  Future dispose() async {
    interpolation.dispose();
    frameNumber.dispose();
    value.dispose();
  }

  @override
  int compareTo(Keyframe<V> other) {
    return frameNumber.value - other.frameNumber.value;
  }

  @override
  V interpolate(V next, double linearRatio) {
    if (interpolation.value == Interpolation.constant) {
      return value.value;
    }
    return value.value.interpolate(next, linearRatio) as V;
  }
}
