import 'package:flutter/foundation.dart';
import 'base_track.dart';
import 'track_type.dart';
import 'clip.dart';
import 'track_item.dart';

class AudioTrack extends BaseTrackImpl<AudioTrackType> {
  final ValueNotifier<double> volume;
  final ValueNotifier<double> pan;
  
  AudioTrack({
    required String label,
    bool enabled = true,
    bool muted = false,
    bool locked = false,
    List<TrackItem>? initialItems,
    double initialVolume = 1.0,
    double initialPan = 0.0,
  }) : 
    volume = ValueNotifier(initialVolume),
    pan = ValueNotifier(initialPan),
    super(
      type: TrackTypes.audio,
      label: label,
      enabled: enabled,
      muted: muted,
      locked: locked,
      initialItems: initialItems,
    );
  
  Future<void> addClip(Clip clip) async {
    if (clip.clipType == ClipType.audio) {
      await addItem(clip);
    } else {
      throw ArgumentError('Only audio clips can be added to AudioTrack');
    }
  }
  
  List<Clip> get audioClips {
    return items.value.whereType<Clip>()
        .where((clip) => clip.clipType == ClipType.audio)
        .toList();
  }
  
  void setVolume(double volume) {
    this.volume.value = volume.clamp(0.0, 2.0);
  }
  
  void setPan(double pan) {
    this.pan.value = pan.clamp(-1.0, 1.0);
  }
  
  double getEffectiveVolumeAtFrame(int frame) {
    if (!enabled || muted) return 0.0;
    
    final clipsAtFrame = audioClips.where((clip) => 
      clip.timeRange.value.contains(frame)
    ).toList();
    
    if (clipsAtFrame.isEmpty) return 0.0;
    
    double totalVolume = 0.0;
    for (final clip in clipsAtFrame) {
      totalVolume += clip.opacity * volume.value;
    }
    
    return totalVolume;
  }
  
  @override
  Future<void> dispose() async {
    volume.dispose();
    pan.dispose();
    await super.dispose();
  }
  
  @override
  BaseTrack<AudioTrackType> clone() {
    final clonedItems = items.value.map((item) => item.clone()).toList();
    return AudioTrack(
      label: label,
      enabled: enabled,
      muted: muted,
      locked: locked,
      initialItems: clonedItems,
      initialVolume: volume.value,
      initialPan: pan.value,
    );
  }
}