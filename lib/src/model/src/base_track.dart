import 'package:flutter/foundation.dart';
import 'track_item.dart';
import 'time_range.dart';
import 'track_type.dart';

abstract class BaseTrack<T extends TrackType> {
  T get type;
  
  String get label;
  
  bool get enabled;
  
  bool get muted;
  
  bool get locked;
  
  ValueListenable<List<TrackItem>> get items;
  
  void setEnabled(bool enabled);
  
  void setMuted(bool muted);
  
  void setLocked(bool locked);
  
  Future<void> addItem(TrackItem item);
  
  Future<void> removeItem(TrackItem item);
  
  Future<void> removeItemAt(int frame);
  
  List<TrackItem> getItemsInRange(TimeRange range);
  
  List<TrackItem> getItemsAtFrame(int frame);
  
  TrackItem? getItemById(String id);
  
  Future<List<TrackItem>> splitItemAt(String itemId, int frame);
  
  Future<void> moveItem(String itemId, int frameOffset);
  
  Future<void> trimItem(String itemId, {int? newStart, int? newEnd});
  
  Future<void> dispose();
  
  BaseTrack<T> clone();
}

abstract class BaseTrackImpl<T extends TrackType> extends BaseTrack<T> {
  @override
  final String label;
  
  @override
  final T type;
  
  @override
  bool enabled;
  
  @override
  bool muted;
  
  @override
  bool locked;
  
  @override
  final ValueNotifier<List<TrackItem>> items;
  
  BaseTrackImpl({
    required this.type,
    required this.label,
    this.enabled = true,
    this.muted = false,
    this.locked = false,
    List<TrackItem>? initialItems,
  }) : items = ValueNotifier(initialItems ?? []);
  
  @override
  void setEnabled(bool enabled) {
    this.enabled = enabled;
  }
  
  @override
  void setMuted(bool muted) {
    this.muted = muted;
  }
  
  @override
  void setLocked(bool locked) {
    this.locked = locked;
  }
  
  @override
  Future<void> addItem(TrackItem item) async {
    if (locked) return;
    
    items.value.add(item);
    items.value.sort((a, b) => a.timeRange.value.startFrame.compareTo(b.timeRange.value.startFrame));
    items.notifyListeners();
  }
  
  @override
  Future<void> removeItem(TrackItem item) async {
    if (locked) return;
    
    items.value.remove(item);
    await item.dispose();
    items.notifyListeners();
  }
  
  @override
  Future<void> removeItemAt(int frame) async {
    if (locked) return;
    
    final itemsAtFrame = getItemsAtFrame(frame);
    for (final item in itemsAtFrame) {
      await removeItem(item);
    }
  }
  
  @override
  List<TrackItem> getItemsInRange(TimeRange range) {
    return items.value.where((item) => 
      item.timeRange.value.overlaps(range)
    ).toList();
  }
  
  @override
  List<TrackItem> getItemsAtFrame(int frame) {
    return items.value.where((item) => 
      item.timeRange.value.contains(frame)
    ).toList();
  }
  
  @override
  TrackItem? getItemById(String id) {
    try {
      return items.value.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<List<TrackItem>> splitItemAt(String itemId, int frame) async {
    if (locked) return [];
    
    final item = getItemById(itemId);
    if (item == null || !item.timeRange.value.contains(frame)) {
      return [];
    }
    
    final originalRange = item.timeRange.value;
    if (frame <= originalRange.startFrame || frame >= originalRange.endFrame) {
      return [item];
    }
    
    final firstRange = TimeRange(
      startFrame: originalRange.startFrame,
      endFrame: frame,
    );
    
    final secondRange = TimeRange(
      startFrame: frame,
      endFrame: originalRange.endFrame,
    );
    
    final secondItem = item.clone();
    secondItem.setTimeRange(secondRange);
    
    item.setTimeRange(firstRange);
    
    await addItem(secondItem);
    
    return [item, secondItem];
  }
  
  @override
  Future<void> moveItem(String itemId, int frameOffset) async {
    if (locked) return;
    
    final item = getItemById(itemId);
    if (item == null) return;
    
    final newRange = item.timeRange.value.shifted(frameOffset);
    item.setTimeRange(newRange);
    
    items.value.sort((a, b) => a.timeRange.value.startFrame.compareTo(b.timeRange.value.startFrame));
    items.notifyListeners();
  }
  
  @override
  Future<void> trimItem(String itemId, {int? newStart, int? newEnd}) async {
    if (locked) return;
    
    final item = getItemById(itemId);
    if (item == null) return;
    
    final newRange = item.timeRange.value.trimmed(
      newStart: newStart,
      newEnd: newEnd,
    );
    
    if (!newRange.isEmpty) {
      item.setTimeRange(newRange);
      items.notifyListeners();
    }
  }
  
  @override
  Future<void> dispose() async {
    for (final item in items.value) {
      await item.dispose();
    }
    items.value.clear();
    items.dispose();
  }
}