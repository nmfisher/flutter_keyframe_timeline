import 'package:flutter/foundation.dart';
import 'package:flutter_keyframe_timeline/src/model/model.dart';
import 'composite_track.dart';
import 'base_track.dart';

abstract class TimelineObject {
  //
  ValueListenable<String> get displayName;

  //
  CompositeTrack get compositeTrack;
  
  //
  @deprecated
  List<Track> get tracks;

  //
  bool hasKeyframesAtFrame(int frame);

  //
  Iterable<Keyframe> getKeyframesAtFrame(int frame);
}

class TimelineObjectImpl extends TimelineObject {
  
  @override
  final CompositeTrack compositeTrack;
  
  @override
  ValueNotifier<String> displayName = ValueNotifier<String>("");

  TimelineObjectImpl({
    CompositeTrack? compositeTrack, 
    List<Track>? tracks, 
    required String name
  }) : compositeTrack = compositeTrack ?? CompositeTrack(label: name) {
    this.displayName.value = name;
    
    if (tracks != null) {
      for (final track in tracks) {
        this.compositeTrack.addTrack(track);
      }
    }
  }
  
  @override
  @deprecated
  List<Track> get tracks {
    return compositeTrack.tracks.value.whereType<Track>().toList();
  }

  @override
  Iterable<Keyframe> getKeyframesAtFrame(int frame) sync* {
    for (final track in tracks) {
      final kf = track.keyframeAt(frame);
      if (kf != null) {
        yield kf;
      }
    }
  }

  @override
  bool hasKeyframesAtFrame(int frame) {
    for (final track in tracks) {
      final kf = track.keyframeAt(frame);
      if (kf != null) {
        return true;
      }
    }
    return false;
  }
}
