abstract class TrackType {
  String get name;
  String get description;
  
  const TrackType();
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrackType && other.runtimeType == runtimeType;
  }
  
  @override
  int get hashCode => runtimeType.hashCode;
  
  @override
  String toString() => name;
}

class AnimationTrackType extends TrackType {
  @override
  String get name => 'animation';
  
  @override
  String get description => 'Track for keyframe-based animation';
  
  const AnimationTrackType();
}

class VideoTrackType extends TrackType {
  @override
  String get name => 'video';
  
  @override
  String get description => 'Track for video clips';
  
  const VideoTrackType();
}

class AudioTrackType extends TrackType {
  @override
  String get name => 'audio';
  
  @override
  String get description => 'Track for audio clips';
  
  const AudioTrackType();
}

class EffectTrackType extends TrackType {
  @override
  String get name => 'effect';
  
  @override
  String get description => 'Track for visual effects';
  
  const EffectTrackType();
}

class TrackTypes {
  static const AnimationTrackType animation = AnimationTrackType();
  static const VideoTrackType video = VideoTrackType();
  static const AudioTrackType audio = AudioTrackType();
  static const EffectTrackType effect = EffectTrackType();
  
  static const List<TrackType> all = [
    animation,
    video,
    audio,
    effect,
  ];
  
  static TrackType? fromName(String name) {
    try {
      return all.firstWhere((type) => type.name == name);
    } catch (e) {
      return null;
    }
  }
}