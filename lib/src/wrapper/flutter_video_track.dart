import 'package:flutter/foundation.dart';
import 'package:timeline_dart/timeline_dart.dart' as dart;

/// Flutter wrapper for VideoTrack that extends the Dart VideoTrack
/// and provides ValueListenable interfaces for properties that need listeners
class FlutterVideoTrack extends dart.VideoTrack {
  late final ValueNotifier<List<dart.TrackItem>> _itemsListenable;
  late final ValueNotifier<List<dart.Clip>> _clipsListenable;
  late final ValueNotifier<List<dart.Transition>> _transitionsListenable;
  
  FlutterVideoTrack({
    required String label,
    bool enabled = true,
    bool muted = false,
    bool locked = false,
    List<dart.TrackItem>? initialItems,
  }) : super(
    label: label,
    enabled: enabled,
    muted: muted,
    locked: locked,
    initialItems: initialItems,
  ) {
    _itemsListenable = ValueNotifier(List<dart.TrackItem>.from(items));
    _clipsListenable = ValueNotifier(List<dart.Clip>.from(clips));
    _transitionsListenable = ValueNotifier(List<dart.Transition>.from(transitions));
  }
  
  /// Create from existing Dart video track
  FlutterVideoTrack.fromDart(dart.VideoTrack dartTrack) : super(
    label: dartTrack.label,
    enabled: dartTrack.enabled,
    muted: dartTrack.muted,
    locked: dartTrack.locked,
    initialItems: List<dart.TrackItem>.from(dartTrack.items),
  ) {
    _itemsListenable = ValueNotifier(List<dart.TrackItem>.from(items));
    _clipsListenable = ValueNotifier(List<dart.Clip>.from(clips));
    _transitionsListenable = ValueNotifier(List<dart.Transition>.from(transitions));
  }
  
  /// Reactive items property - used by UI for listening to changes
  ValueListenable<List<dart.TrackItem>> get itemsListenable => _itemsListenable;
  
  /// Reactive clips property - used by UI for listening to changes
  ValueListenable<List<dart.Clip>> get clipsListenable => _clipsListenable;
  
  /// Reactive transitions property - used by UI for listening to changes
  ValueListenable<List<dart.Transition>> get transitionsListenable => _transitionsListenable;
  
  @override
  Future<void> addClip(dart.Clip clip) async {
    await super.addClip(clip);
    _syncCollections();
  }
  
  @override
  Future<void> removeClip(dart.Clip clip) async {
    await super.removeClip(clip);
    _syncCollections();
  }
  
  @override
  Future<void> addTransition(dart.Transition transition) async {
    await super.addTransition(transition);
    _syncCollections();
  }
  
  @override
  Future<void> removeTransition(dart.Transition transition) async {
    await super.removeTransition(transition);
    _syncCollections();
  }
  
  @override
  Future<void> addItem(dart.TrackItem item) async {
    await super.addItem(item);
    _syncCollections();
  }
  
  @override
  Future<void> removeItem(dart.TrackItem item) async {
    await super.removeItem(item);
    _syncCollections();
  }
  
  /// Sync the reactive collections with the underlying model
  void _syncCollections() {
    _itemsListenable.value = List<dart.TrackItem>.from(items);
    _clipsListenable.value = List<dart.Clip>.from(clips);
    _transitionsListenable.value = List<dart.Transition>.from(transitions);
  }
  
  @override
  Future<void> dispose() async {
    _itemsListenable.dispose();
    _clipsListenable.dispose();
    _transitionsListenable.dispose();
    await super.dispose();
  }
  
  @override
  FlutterVideoTrack clone() {
    return FlutterVideoTrack(
      label: label,
      enabled: enabled,
      muted: muted,
      locked: locked,
      initialItems: items.map((item) => item.clone()).toList(),
    );
  }
}