import 'package:flutter/foundation.dart';
import 'package:timeline_dart/timeline_dart.dart' as dart;

/// Flutter wrapper for TimelineObject that extends the Dart TimelineObject
/// and provides ValueListenable interfaces for properties that need listeners
class FlutterTimelineObject extends dart.TimelineObjectImpl {
  late final ValueNotifier<List<dart.BaseTrack>> _tracksListenable;
  late final ValueNotifier<String> _displayNameListenable;
  
  FlutterTimelineObject({
    required List<dart.BaseTrack> tracks,
    required String name,
  }) : super(
    tracks: tracks,
    name: name,
  ) {
    _tracksListenable = ValueNotifier(List<dart.BaseTrack>.from(tracks));
    _displayNameListenable = ValueNotifier(name);
  }
  
  /// Create from existing Dart timeline object
  FlutterTimelineObject.fromDart(dart.TimelineObjectImpl dartObject) : super(
    tracks: List<dart.BaseTrack>.from(dartObject.tracks),
    name: dartObject.displayName,
  ) {
    _tracksListenable = ValueNotifier(List<dart.BaseTrack>.from(tracks));
    _displayNameListenable = ValueNotifier(dartObject.displayName);
  }
  
  /// Reactive tracks property - used by UI for listening to changes
  ValueListenable<List<dart.BaseTrack>> get tracksListenable => _tracksListenable;
  
  /// Reactive displayName property - used by UI for listening to changes
  ValueListenable<String> get displayNameListenable => _displayNameListenable;
  
  /// Sync the reactive tracks with the underlying model
  void _syncTracks() {
    _tracksListenable.value = List<dart.BaseTrack>.from(tracks);
  }
  
  Future<void> dispose() async {
    _tracksListenable.dispose();
    _displayNameListenable.dispose();
  }
  
  FlutterTimelineObject clone() {
    return FlutterTimelineObject(
      tracks: tracks.map((track) => track.clone()).toList(),
      name: displayName,
    );
  }
}