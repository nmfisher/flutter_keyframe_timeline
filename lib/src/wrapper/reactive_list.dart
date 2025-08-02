import 'package:flutter/foundation.dart';

/// A reactive wrapper around a regular List that provides ValueNotifier functionality
/// This allows pure Dart lists to be used with Flutter's reactive system
class ReactiveList<T> extends ValueNotifier<List<T>> {
  final List<T> _dartList;
  
  /// Creates a reactive wrapper around the provided Dart list
  ReactiveList(this._dartList) : super(List.from(_dartList));
  
  /// Updates the reactive value to match the current state of the wrapped list
  void _sync() {
    value = List.from(_dartList);
  }
  
  /// Adds an item to both the wrapped list and notifies listeners
  void add(T item) {
    _dartList.add(item);
    _sync();
  }
  
  /// Removes an item from both the wrapped list and notifies listeners
  bool remove(T item) {
    final result = _dartList.remove(item);
    if (result) {
      _sync();
    }
    return result;
  }
  
  /// Removes an item at the specified index and notifies listeners
  T removeAt(int index) {
    final result = _dartList.removeAt(index);
    _sync();
    return result;
  }
  
  /// Inserts an item at the specified index and notifies listeners
  void insert(int index, T item) {
    _dartList.insert(index, item);
    _sync();
  }
  
  /// Clears all items from both the wrapped list and notifies listeners
  void clear() {
    _dartList.clear();
    _sync();
  }
  
  /// Sorts the wrapped list using the provided compare function and notifies listeners
  void sort([int Function(T a, T b)? compare]) {
    _dartList.sort(compare);
    _sync();
  }
  
  /// Gets the length of the wrapped list
  int get length => _dartList.length;
  
  /// Gets whether the wrapped list is empty
  bool get isEmpty => _dartList.isEmpty;
  
  /// Gets whether the wrapped list is not empty
  bool get isNotEmpty => _dartList.isNotEmpty;
  
  /// Access the wrapped list directly (use with caution - manual sync required)
  List<T> get dartList => _dartList;
  
  /// Manually sync the reactive value with the wrapped list
  /// Call this if you modify the dartList directly
  void manualSync() {
    _sync();
  }
}