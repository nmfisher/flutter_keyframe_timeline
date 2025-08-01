import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'channel_types.dart';
import 'track_item.dart';
import 'time_range.dart';

enum Interpolation { linear, constant }

//
//
abstract class Keyframe<V extends ChannelValue> extends TrackItem {
  // The interpolation method for this keyframe. See [KeyframeTrack.calculate]
  // for an explanation of how this is applied.
  ValueListenable<Interpolation> get interpolation;

  // The value of this keyframe.
  ValueListenable<V> get value;

  V interpolate(V next, double linearRatio);

  // The frame number for this keyframe.
  ValueListenable<int> get frameNumber;

  // Update the frame number for this keyframe.
  Future setFrameNumber(int frameNumber);
}

class KeyframeImpl<V extends ChannelValue> extends TrackItemImpl implements Keyframe<V>, Comparable<Keyframe<V>> {
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
    String? id,
    int layerIndex = 0,
    bool enabled = true,
  }) : super(
    initialTimeRange: TimeRange(
      startFrame: frameNumber,
      endFrame: frameNumber + 1,
    ),
    id: id ?? const Uuid().v4(),
    layerIndex: layerIndex,
    enabled: enabled,
  ) {
    this.value = ValueNotifier<V>(value);
    this.interpolation.value = interpolation;
    this.frameNumber.value = frameNumber;
    this.frameNumber.addListener(_onFrameNumberChanged);
  }

  void _onFrameNumberChanged() {
    final newRange = TimeRange(
      startFrame: frameNumber.value,
      endFrame: frameNumber.value + 1,
    );
    setTimeRange(newRange);
  }

  @override
  Future setFrameNumber(int frameNumber) async {
    this.frameNumber.value = frameNumber;
  }

  @override
  Future dispose() async {
    frameNumber.removeListener(_onFrameNumberChanged);
    interpolation.dispose();
    frameNumber.dispose();
    value.dispose();
    await super.dispose();
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

  @override
  TrackItemType get type => TrackItemType.keyframe;

  @override
  Keyframe<V> clone() {
    return KeyframeImpl<V>(
      frameNumber: frameNumber.value,
      value: value.value,
      interpolation: interpolation.value,
      id: null, // Generate new ID for clone
      layerIndex: layerIndex,
      enabled: enabled,
    );
  }

  @override
  void setTimeRange(TimeRange range) {
    super.setTimeRange(range);
    if (range.startFrame != frameNumber.value) {
      setFrameNumber(range.startFrame);
    }
  }
}
