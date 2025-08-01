import 'package:uuid/uuid.dart';
import 'track_item.dart';
import 'time_range.dart';

enum ClipType {
  video,
  audio,
  image,
  text,
  effect,
}

abstract class MediaSource {
  String get path;
  ClipType get type;
  int? get durationFrames;
}

class FileMediaSource implements MediaSource {
  @override
  final String path;
  
  @override
  final ClipType type;
  
  @override
  final int? durationFrames;
  
  const FileMediaSource({
    required this.path,
    required this.type,
    this.durationFrames,
  });
}

class GeneratedMediaSource implements MediaSource {
  @override
  final String path;
  
  @override
  final ClipType type;
  
  @override
  final int? durationFrames;
  
  final Map<String, dynamic> parameters;
  
  const GeneratedMediaSource({
    required this.path,
    required this.type,
    required this.parameters,
    this.durationFrames,
  });
}

class Clip extends TrackItemImpl {
  final MediaSource source;
  final TimeRange sourceRange;
  final Map<String, dynamic> effects;
  final double opacity;
  final bool visible;
  
  Clip({
    required this.source,
    required TimeRange trackRange,
    TimeRange? sourceRange,
    String? id,
    int layerIndex = 0,
    bool enabled = true,
    this.effects = const {},
    this.opacity = 1.0,
    this.visible = true,
  }) : 
    sourceRange = sourceRange ?? TimeRange(
      startFrame: 0,
      endFrame: source.durationFrames ?? trackRange.duration,
    ),
    super(
      initialTimeRange: trackRange,
      id: id ?? const Uuid().v4(),
      layerIndex: layerIndex,
      enabled: enabled,
    );
  
  @override
  TrackItemType get type => TrackItemType.clip;
  
  ClipType get clipType => source.type;
  
  bool get hasFixedDuration => source.durationFrames != null;
  
  void setOpacity(double opacity) {
    if (opacity >= 0.0 && opacity <= 1.0) {
      // This would need to notify listeners in a real implementation
    }
  }
  
  void setVisible(bool visible) {
    // This would need to notify listeners in a real implementation
  }
  
  void addEffect(String name, Map<String, dynamic> parameters) {
    effects[name] = parameters;
    // This would need to notify listeners in a real implementation
  }
  
  void removeEffect(String name) {
    effects.remove(name);
    // This would need to notify listeners in a real implementation
  }
  
  void updateEffect(String name, Map<String, dynamic> parameters) {
    if (effects.containsKey(name)) {
      effects[name] = parameters;
      // This would need to notify listeners in a real implementation
    }
  }
  
  TimeRange getActualSourceRange() {
    if (hasFixedDuration) {
      final maxEnd = sourceRange.startFrame + source.durationFrames!;
      return TimeRange(
        startFrame: sourceRange.startFrame,
        endFrame: sourceRange.endFrame > maxEnd ? maxEnd : sourceRange.endFrame,
      );
    }
    return sourceRange;
  }
  
  @override
  void setTimeRange(TimeRange range) {
    super.setTimeRange(range);
    
    if (hasFixedDuration && range.duration > source.durationFrames!) {
      super.setTimeRange(TimeRange(
        startFrame: range.startFrame,
        endFrame: range.startFrame + source.durationFrames!,
      ));
    }
  }
  
  @override
  Clip clone() {
    return Clip(
      source: source,
      trackRange: timeRange.value,
      sourceRange: sourceRange,
      layerIndex: layerIndex,
      enabled: enabled,
      effects: Map<String, dynamic>.from(effects),
      opacity: opacity,
      visible: visible,
    );
  }
  
  @override
  String toString() {
    return 'Clip(${source.path}, ${timeRange.value}, layer: $layerIndex)';
  }
}