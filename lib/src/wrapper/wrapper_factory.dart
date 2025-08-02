import 'package:timeline_dart/timeline_dart.dart' as dart;
import 'flutter_base_track.dart';
import 'flutter_timeline_object.dart';
import 'flutter_keyframe_track.dart';
import 'flutter_keyframe.dart';
import 'flutter_audio_track.dart';
import 'flutter_video_track.dart';
import 'flutter_clip.dart';
import 'flutter_transition.dart';

/// Factory class for creating Flutter wrappers around Dart timeline models
class WrapperFactory {
  
  // Private constructor to prevent instantiation
  WrapperFactory._();
  
  /// Wrap a TrackItem with appropriate Flutter wrapper
  /// Note: For Keyframes, use wrapKeyframe() instead for proper typing
  static dynamic wrapTrackItem(dart.TrackItem dartItem) {
    if (dartItem is dart.Clip) {
      return FlutterClip.fromDart(dartItem);
    } else if (dartItem is dart.Transition) {
      return FlutterTransition.fromDart(dartItem);
    } else if (dartItem is dart.Keyframe) {
      return _wrapKeyframe(dartItem);
    } else {
      throw ArgumentError('Unsupported TrackItem type: ${dartItem.runtimeType}');
    }
  }
  
  /// Wrap a generic Keyframe (type inference helper)
  static FlutterKeyframe _wrapKeyframe(dart.Keyframe dartKeyframe) {
    // Since we can't determine the generic type at runtime easily,
    // we'll create a generic wrapper. In practice, consumers should
    // use the typed factory methods below when they know the type.
    if (dartKeyframe is dart.KeyframeImpl) {
      return FlutterKeyframe.fromDart(dartKeyframe);
    } else {
      throw ArgumentError('Unsupported Keyframe type: ${dartKeyframe.runtimeType}');
    }
  }
  
  /// Wrap a typed Keyframe
  static FlutterKeyframe<V> wrapKeyframe<V extends dart.ChannelValue>(dart.Keyframe<V> dartKeyframe) {
    if (dartKeyframe is dart.KeyframeImpl<V>) {
      return FlutterKeyframe<V>.fromDart(dartKeyframe);
    } else {
      throw ArgumentError('Unsupported Keyframe type: ${dartKeyframe.runtimeType}');
    }
  }
  
  /// Wrap a BaseTrack with appropriate Flutter wrapper
  static dynamic wrapBaseTrack(dart.BaseTrack dartTrack) {
    if (dartTrack is dart.AudioTrack) {
      return FlutterAudioTrack.fromDart(dartTrack);
    } else if (dartTrack is dart.VideoTrack) {
      return FlutterVideoTrack.fromDart(dartTrack);
    } else if (dartTrack is dart.KeyframeTrack) {
      return _wrapKeyframeTrack(dartTrack);
    } else if (dartTrack is dart.BaseTrackImpl) {
      return FlutterBaseTrack.fromDart(dartTrack);
    } else {
      throw ArgumentError('Unsupported BaseTrack type: ${dartTrack.runtimeType}');
    }
  }
  
  /// Wrap a generic KeyframeTrack (type inference helper)
  static FlutterKeyframeTrack _wrapKeyframeTrack(dart.KeyframeTrack dartTrack) {
    // Since we can't determine the generic type at runtime easily,
    // consumers should use the typed factory methods below when they know the type.
    if (dartTrack is dart.KeyframeTrackImpl) {
      return FlutterKeyframeTrack.fromDart(dartTrack);
    } else {
      throw ArgumentError('Unsupported KeyframeTrack type: ${dartTrack.runtimeType}');
    }
  }
  
  /// Wrap a typed KeyframeTrack
  static FlutterKeyframeTrack<V> wrapKeyframeTrack<V extends dart.ChannelValue>(dart.KeyframeTrack<V> dartTrack) {
    if (dartTrack is dart.KeyframeTrackImpl<V>) {
      return FlutterKeyframeTrack<V>.fromDart(dartTrack);
    } else {
      throw ArgumentError('Unsupported KeyframeTrack type: ${dartTrack.runtimeType}');
    }
  }
  
  /// Wrap a TimelineObject with appropriate Flutter wrapper
  static FlutterTimelineObject wrapTimelineObject(dart.TimelineObject dartObject) {
    if (dartObject is dart.TimelineObjectImpl) {
      return FlutterTimelineObject.fromDart(dartObject);
    } else {
      throw ArgumentError('Unsupported TimelineObject type: ${dartObject.runtimeType}');
    }
  }
  
  /// Wrap a Clip
  static FlutterClip wrapClip(dart.Clip dartClip) {
    return FlutterClip.fromDart(dartClip);
  }
  
  /// Wrap a Transition
  static FlutterTransition wrapTransition(dart.Transition dartTransition) {
    return FlutterTransition.fromDart(dartTransition);
  }
  
  /// Wrap an AudioTrack
  static FlutterAudioTrack wrapAudioTrack(dart.AudioTrack dartAudioTrack) {
    return FlutterAudioTrack.fromDart(dartAudioTrack);
  }
  
  /// Wrap a VideoTrack
  static FlutterVideoTrack wrapVideoTrack(dart.VideoTrack dartVideoTrack) {
    return FlutterVideoTrack.fromDart(dartVideoTrack);
  }
  
  /// Wrap a list of TrackItems
  /// Note: Returns List<dynamic> due to mixed types including FlutterKeyframes
  static List<dynamic> wrapTrackItems(List<dart.TrackItem> dartItems) {
    return dartItems.map((item) => wrapTrackItem(item)).toList();
  }
  
  /// Wrap a list of BaseTracks
  static List<dynamic> wrapBaseTracks(List<dart.BaseTrack> dartTracks) {
    return dartTracks.map((track) => wrapBaseTrack(track)).toList();
  }
  
  /// Wrap a list of Keyframes
  static List<FlutterKeyframe<V>> wrapKeyframes<V extends dart.ChannelValue>(List<dart.Keyframe<V>> dartKeyframes) {
    return dartKeyframes.map((keyframe) => wrapKeyframe<V>(keyframe)).toList();
  }
}