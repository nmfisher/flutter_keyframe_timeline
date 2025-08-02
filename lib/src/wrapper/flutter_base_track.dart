import 'package:flutter/foundation.dart';
import 'package:timeline_dart/timeline_dart.dart' as dart;

/// Flutter wrapper for BaseTrack that extends the Dart BaseTrack
/// and provides ValueListenable interfaces for properties that need listeners
class FlutterBaseTrack<T extends dart.TrackType> extends dart.BaseTrackImpl<T> {
  late final ValueNotifier<List<dart.TrackItem>> _itemsListenable;
  
  FlutterBaseTrack({
    required T type,
    required String label,
    bool enabled = true,
    bool muted = false,
    bool locked = false,
    List<dart.TrackItem>? initialItems,
  }) : super(
    type: type,
    label: label,
    enabled: enabled,
    muted: muted,
    locked: locked,
    initialItems: initialItems,
  ) {
    _itemsListenable = ValueNotifier(List<dart.TrackItem>.from(items));
  }
  
  /// Create from existing Dart base track
  FlutterBaseTrack.fromDart(dart.BaseTrackImpl<T> dartTrack) : super(
    type: dartTrack.type,
    label: dartTrack.label,
    enabled: dartTrack.enabled,
    muted: dartTrack.muted,
    locked: dartTrack.locked,
    initialItems: List<dart.TrackItem>.from(dartTrack.items),
  ) {
    _itemsListenable = ValueNotifier(List<dart.TrackItem>.from(items));
  }
  
  /// Reactive items property - used by UI for listening to changes
  ValueListenable<List<dart.TrackItem>> get itemsListenable => _itemsListenable;
  
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
  Future<void> removeItemAt(int frame) async {
    await super.removeItemAt(frame);
    _syncItems();
  }
  
  @override
  Future<List<dart.TrackItem>> splitItemAt(String itemId, int frame) async {
    final result = await super.splitItemAt(itemId, frame);
    _syncItems();
    return result;
  }
  
  @override
  Future<void> moveItem(String itemId, int frameOffset) async {
    await super.moveItem(itemId, frameOffset);
    _syncItems();
  }
  
  @override
  Future<void> trimItem(String itemId, {int? newStart, int? newEnd}) async {
    await super.trimItem(itemId, newStart: newStart, newEnd: newEnd);
    _syncItems();
  }
  
  /// Sync the reactive items with the underlying model
  void _syncItems() {
    _itemsListenable.value = List<dart.TrackItem>.from(items);
  }
  
  @override
  Future<void> dispose() async {
    _itemsListenable.dispose();
    await super.dispose();
  }
  
  @override
  FlutterBaseTrack<T> clone() {
    return FlutterBaseTrack<T>(
      type: type,
      label: label,
      enabled: enabled,
      muted: muted,
      locked: locked,
      initialItems: items.map((item) => item.clone()).toList(),
    );
  }
}