import 'package:flutter/foundation.dart';
import 'base_track.dart';
import 'track_item.dart';
import 'time_range.dart';
import 'clip.dart';
import 'transition.dart';

enum BlendMode {
  normal,
  multiply,
  screen,
  overlay,
  softLight,
  hardLight,
  colorDodge,
  colorBurn,
  darken,
  lighten,
  difference,
  exclusion,
}

class CompositeTrack extends BaseTrackImpl {
  final ValueNotifier<List<BaseTrack>> tracks;
  final ValueNotifier<BlendMode> blendMode;
  
  CompositeTrack({
    required String label,
    List<BaseTrack>? initialTracks,
    BlendMode initialBlendMode = BlendMode.normal,
    bool enabled = true,
    bool muted = false,
    bool locked = false,
  }) : 
    tracks = ValueNotifier(initialTracks ?? []),
    blendMode = ValueNotifier(initialBlendMode),
    super(
      type: TrackType.composite,
      label: label,
      enabled: enabled,
      muted: muted,
      locked: locked,
    );
  
  void addTrack(BaseTrack track) {
    if (locked) return;
    
    tracks.value.add(track);
    tracks.notifyListeners();
  }
  
  void removeTrack(BaseTrack track) {
    if (locked) return;
    
    tracks.value.remove(track);
    track.dispose();
    tracks.notifyListeners();
  }
  
  void insertTrack(int index, BaseTrack track) {
    if (locked) return;
    
    tracks.value.insert(index, track);
    tracks.notifyListeners();
  }
  
  void moveTrackTo(BaseTrack track, int newIndex) {
    if (locked) return;
    
    final currentIndex = tracks.value.indexOf(track);
    if (currentIndex == -1) return;
    
    tracks.value.removeAt(currentIndex);
    tracks.value.insert(newIndex, track);
    tracks.notifyListeners();
  }
  
  List<BaseTrack> getTracksOfType(TrackType type) {
    return tracks.value.where((track) => track.type == type).toList();
  }
  
  BaseTrack? getTrackByLabel(String label) {
    try {
      return tracks.value.firstWhere((track) => track.label == label);
    } catch (e) {
      return null;
    }
  }
  
  @override
  List<TrackItem> getItemsAtFrame(int frame) {
    final allItems = <TrackItem>[];
    for (final track in tracks.value) {
      allItems.addAll(track.getItemsAtFrame(frame));
    }
    allItems.sort((a, b) => a.layerIndex.compareTo(b.layerIndex));
    return allItems;
  }
  
  @override
  List<TrackItem> getItemsInRange(TimeRange range) {
    final allItems = <TrackItem>[];
    for (final track in tracks.value) {
      allItems.addAll(track.getItemsInRange(range));
    }
    allItems.sort((a, b) => a.timeRange.value.startFrame.compareTo(b.timeRange.value.startFrame));
    return allItems;
  }
  
  List<Clip> getClipsAtFrame(int frame) {
    return getItemsAtFrame(frame).whereType<Clip>().toList();
  }
  
  List<Transition> getTransitionsAtFrame(int frame) {
    return getItemsAtFrame(frame).whereType<Transition>().toList();
  }
  
  List<Clip> getActiveClipsAtFrame(int frame) {
    final clips = getClipsAtFrame(frame);
    final transitions = getTransitionsAtFrame(frame);
    
    final activeClips = <Clip>[];
    
    for (final clip in clips) {
      if (!clip.enabled || !clip.visible) continue;
      
      bool isAffectedByTransition = false;
      for (final transition in transitions) {
        if (transition.sourceClip == clip || transition.targetClip == clip) {
          isAffectedByTransition = true;
          break;
        }
      }
      
      if (!isAffectedByTransition) {
        activeClips.add(clip);
      }
    }
    
    return activeClips;
  }
  
  double getCompositeOpacityAtFrame(int frame) {
    if (!enabled || muted) return 0.0;
    
    final clips = getActiveClipsAtFrame(frame);
    final transitions = getTransitionsAtFrame(frame);
    
    if (clips.isEmpty && transitions.isEmpty) return 0.0;
    
    double totalOpacity = 0.0;
    int count = 0;
    
    for (final clip in clips) {
      totalOpacity += clip.opacity;
      count++;
    }
    
    for (final transition in transitions) {
      final progress = transition.getProgress(frame);
      final sourceOpacity = transition.sourceClip?.opacity ?? 0.0;
      final targetOpacity = transition.targetClip?.opacity ?? 0.0;
      
      final transitionOpacity = sourceOpacity * (1.0 - progress) + targetOpacity * progress;
      totalOpacity += transitionOpacity;
      count++;
    }
    
    return count > 0 ? totalOpacity / count : 0.0;
  }
  
  TimeRange? getTotalTimeRange() {
    int? minStart;
    int? maxEnd;
    
    for (final track in tracks.value) {
      for (final item in track.items.value) {
        final range = item.timeRange.value;
        minStart = minStart == null ? range.startFrame : 
                  (range.startFrame < minStart ? range.startFrame : minStart);
        maxEnd = maxEnd == null ? range.endFrame : 
                (range.endFrame > maxEnd ? range.endFrame : maxEnd);
      }
    }
    
    return minStart != null && maxEnd != null ? 
           TimeRange(startFrame: minStart, endFrame: maxEnd) : null;
  }
  
  void setBlendMode(BlendMode mode) {
    blendMode.value = mode;
  }
  
  @override
  Future<void> dispose() async {
    for (final track in tracks.value) {
      await track.dispose();
    }
    tracks.value.clear();
    tracks.dispose();
    blendMode.dispose();
    await super.dispose();
  }
  
  @override
  CompositeTrack clone() {
    final clonedTracks = tracks.value.map((track) => track.clone()).toList();
    return CompositeTrack(
      label: label,
      initialTracks: clonedTracks,
      initialBlendMode: blendMode.value,
      enabled: enabled,
      muted: muted,
      locked: locked,
    );
  }
  
  @override
  String toString() {
    return 'CompositeTrack($label, ${tracks.value.length} tracks)';
  }
}