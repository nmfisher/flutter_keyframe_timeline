import 'base_track.dart';
import 'track_type.dart';
import 'clip.dart';
import 'transition.dart';
import 'track_item.dart';

class VideoTrack extends BaseTrackImpl<VideoTrackType> {
  VideoTrack({
    required String label,
    bool enabled = true,
    bool muted = false,
    bool locked = false,
    List<TrackItem>? initialItems,
  }) : super(
    type: TrackTypes.video,
    label: label,
    enabled: enabled,
    muted: muted,
    locked: locked,
    initialItems: initialItems,
  );
  
  Future<void> addClip(Clip clip) async {
    await addItem(clip);
  }
  
  Future<void> removeClip(Clip clip) async {
    await removeItem(clip);
  }
  
  Future<void> addTransition(Transition transition) async {
    await addItem(transition);
  }
  
  Future<void> removeTransition(Transition transition) async {
    await removeItem(transition);
  }
  
  List<Clip> get clips {
    return items.value.whereType<Clip>().toList();
  }
  
  List<Transition> get transitions {
    return items.value.whereType<Transition>().toList();
  }
  
  List<Clip> getClipsInRange(int startFrame, int endFrame) {
    return clips.where((clip) => 
      clip.timeRange.value.startFrame < endFrame && 
      clip.timeRange.value.endFrame > startFrame
    ).toList();
  }
  
  List<Transition> getTransitionsInRange(int startFrame, int endFrame) {
    return transitions.where((transition) => 
      transition.timeRange.value.startFrame < endFrame && 
      transition.timeRange.value.endFrame > startFrame
    ).toList();
  }
  
  @override
  BaseTrack<VideoTrackType> clone() {
    final clonedItems = items.value.map((item) => item.clone()).toList();
    return VideoTrack(
      label: label,
      enabled: enabled,
      muted: muted,
      locked: locked,
      initialItems: clonedItems,
    );
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
  }
}