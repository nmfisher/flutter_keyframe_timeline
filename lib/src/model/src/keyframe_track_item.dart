import 'package:uuid/uuid.dart';
import 'track_item.dart';
import 'time_range.dart';
import 'keyframe.dart';
import 'channel_types.dart';

class KeyframeTrackItem<V extends ChannelValue> extends TrackItemImpl {
  final Keyframe<V> keyframe;
  
  KeyframeTrackItem({
    required this.keyframe,
    String? id,
    int layerIndex = 0,
    bool enabled = true,
  }) : super(
    initialTimeRange: TimeRange(
      startFrame: keyframe.frameNumber.value,
      endFrame: keyframe.frameNumber.value + 1,
    ),
    id: id ?? const Uuid().v4(),
    layerIndex: layerIndex,
    enabled: enabled,
  ) {
    keyframe.frameNumber.addListener(_onKeyframeFrameChanged);
  }
  
  @override
  TrackItemType get type => TrackItemType.keyframe;
  
  void _onKeyframeFrameChanged() {
    final newRange = TimeRange(
      startFrame: keyframe.frameNumber.value,
      endFrame: keyframe.frameNumber.value + 1,
    );
    setTimeRange(newRange);
  }
  
  @override
  void setTimeRange(TimeRange range) {
    super.setTimeRange(range);
    if (range.startFrame != keyframe.frameNumber.value) {
      keyframe.setFrameNumber(range.startFrame);
    }
  }
  
  @override
  Future<void> dispose() async {
    keyframe.frameNumber.removeListener(_onKeyframeFrameChanged);
    await keyframe.dispose();
    await super.dispose();
  }
  
  @override
  KeyframeTrackItem<V> clone() {
    final clonedKeyframe = KeyframeImpl<V>(
      frameNumber: keyframe.frameNumber.value,
      value: keyframe.value.value,
      interpolation: keyframe.interpolation.value,
    );
    
    return KeyframeTrackItem<V>(
      keyframe: clonedKeyframe,
      layerIndex: layerIndex,
      enabled: enabled,
    );
  }
}