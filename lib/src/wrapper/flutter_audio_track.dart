import 'package:flutter/foundation.dart';
import 'package:timeline_dart/timeline_dart.dart' as dart;

/// Flutter wrapper for AudioTrack that extends the Dart AudioTrack
/// and provides ValueListenable interfaces for properties that need listeners
class FlutterAudioTrack extends dart.AudioTrack {
  late final ValueNotifier<List<dart.TrackItem>> _itemsListenable;
  late final ValueNotifier<double> _volumeListenable;
  late final ValueNotifier<double> _panListenable;
  
  FlutterAudioTrack({
    required String label,
    bool enabled = true,
    bool muted = false,
    bool locked = false,
    List<dart.TrackItem>? initialItems,
    double initialVolume = 1.0,
    double initialPan = 0.0,
  }) : super(
    label: label,
    enabled: enabled,
    muted: muted,
    locked: locked,
    initialItems: initialItems,
    initialVolume: initialVolume,
    initialPan: initialPan,
  ) {
    _itemsListenable = ValueNotifier(List<dart.TrackItem>.from(items));
    _volumeListenable = ValueNotifier(volume);
    _panListenable = ValueNotifier(pan);
  }
  
  /// Create from existing Dart audio track
  FlutterAudioTrack.fromDart(dart.AudioTrack dartTrack) : super(
    label: dartTrack.label,
    enabled: dartTrack.enabled,
    muted: dartTrack.muted,
    locked: dartTrack.locked,
    initialItems: List<dart.TrackItem>.from(dartTrack.items),
    initialVolume: dartTrack.volume,
    initialPan: dartTrack.pan,
  ) {
    _itemsListenable = ValueNotifier(List<dart.TrackItem>.from(items));
    _volumeListenable = ValueNotifier(volume);
    _panListenable = ValueNotifier(pan);
  }
  
  /// Reactive items property - used by UI for listening to changes
  ValueListenable<List<dart.TrackItem>> get itemsListenable => _itemsListenable;
  
  /// Reactive volume property - used by UI for listening to changes
  ValueListenable<double> get volumeListenable => _volumeListenable;
  
  /// Reactive pan property - used by UI for listening to changes
  ValueListenable<double> get panListenable => _panListenable;
  
  @override
  Future<void> addClip(dart.Clip clip) async {
    await super.addClip(clip);
    _syncItems();
  }
  
  @override
  Future<void> addItem(dart.TrackItem item) async {
    await super.addItem(item);
    _syncItems();
  }
  
  @override
  Future<void> removeItem(dart.TrackItem item) async {
    await super.removeItem(item);
    _syncItems();
  }
  
  @override
  void setVolume(double volume) {
    super.setVolume(volume);
    _volumeListenable.value = this.volume;
  }
  
  @override
  void setPan(double pan) {
    super.setPan(pan);
    _panListenable.value = this.pan;
  }
  
  /// Sync the reactive items with the underlying model
  void _syncItems() {
    _itemsListenable.value = List<dart.TrackItem>.from(items);
  }
  
  @override
  Future<void> dispose() async {
    _itemsListenable.dispose();
    _volumeListenable.dispose();
    _panListenable.dispose();
    await super.dispose();
  }
  
  @override
  FlutterAudioTrack clone() {
    return FlutterAudioTrack(
      label: label,
      enabled: enabled,
      muted: muted,
      locked: locked,
      initialItems: items.map((item) => item.clone()).toList(),
      initialVolume: volume,
      initialPan: pan,
    );
  }
}