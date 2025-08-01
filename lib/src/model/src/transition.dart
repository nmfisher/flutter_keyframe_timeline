import 'package:flutter/animation.dart';
import 'package:uuid/uuid.dart';
import 'track_item.dart';
import 'time_range.dart';
import 'clip.dart';

enum TransitionType {
  crossfade,
  dissolve,
  wipeLeft,
  wipeRight,
  wipeUp,
  wipeDown,
  slideLeft,
  slideRight,
  slideUp,
  slideDown,
  fade,
  custom,
}

class Transition extends TrackItemImpl {
  final TransitionType transitionType;
  final Curve curve;
  final Map<String, dynamic> parameters;
  
  Clip? _sourceClip;
  Clip? _targetClip;
  
  Transition({
    required this.transitionType,
    required TimeRange timeRange,
    String? id,
    int layerIndex = 0,
    bool enabled = true,
    this.curve = Curves.linear,
    this.parameters = const {},
    Clip? sourceClip,
    Clip? targetClip,
  }) : 
    _sourceClip = sourceClip,
    _targetClip = targetClip,
    super(
      initialTimeRange: timeRange,
      id: id ?? const Uuid().v4(),
      layerIndex: layerIndex,
      enabled: enabled,
    );
  
  @override
  TrackItemType get type => TrackItemType.transition;
  
  Clip? get sourceClip => _sourceClip;
  Clip? get targetClip => _targetClip;
  
  void setSourceClip(Clip? clip) {
    _sourceClip = clip;
  }
  
  void setTargetClip(Clip? clip) {
    _targetClip = clip;
  }
  
  double getProgress(int frame) {
    if (!timeRange.value.contains(frame)) {
      return frame < timeRange.value.startFrame ? 0.0 : 1.0;
    }
    
    final progress = (frame - timeRange.value.startFrame) / timeRange.value.duration;
    return curve.transform(progress);
  }
  
  bool canApplyToClips(Clip? source, Clip? target) {
    if (source == null && target == null) return false;
    
    switch (transitionType) {
      case TransitionType.crossfade:
      case TransitionType.dissolve:
      case TransitionType.fade:
        return true;
      case TransitionType.wipeLeft:
      case TransitionType.wipeRight:
      case TransitionType.wipeUp:
      case TransitionType.wipeDown:
      case TransitionType.slideLeft:
      case TransitionType.slideRight:
      case TransitionType.slideUp:
      case TransitionType.slideDown:
        return source?.clipType == ClipType.video && target?.clipType == ClipType.video;
      case TransitionType.custom:
        return parameters.containsKey('canApply') ? 
               parameters['canApply'](source, target) : true;
    }
  }
  
  void updateParameter(String key, dynamic value) {
    parameters[key] = value;
    // This would need to notify listeners in a real implementation
  }
  
  dynamic getParameter(String key, {dynamic defaultValue}) {
    return parameters[key] ?? defaultValue;
  }
  
  Map<String, dynamic> getParametersForFrame(int frame) {
    final progress = getProgress(frame);
    final frameParams = Map<String, dynamic>.from(parameters);
    frameParams['progress'] = progress;
    frameParams['frame'] = frame;
    frameParams['startFrame'] = timeRange.value.startFrame;
    frameParams['endFrame'] = timeRange.value.endFrame;
    return frameParams;
  }
  
  @override
  void setTimeRange(TimeRange range) {
    super.setTimeRange(range);
    
    if (range.duration <= 0) {
      super.setTimeRange(TimeRange(
        startFrame: range.startFrame,
        endFrame: range.startFrame + 1,
      ));
    }
  }
  
  @override
  Transition clone() {
    return Transition(
      transitionType: transitionType,
      timeRange: timeRange.value,
      layerIndex: layerIndex,
      enabled: enabled,
      curve: curve,
      parameters: Map<String, dynamic>.from(parameters),
      sourceClip: _sourceClip?.clone(),
      targetClip: _targetClip?.clone(),
    );
  }
  
  @override
  String toString() {
    return 'Transition($transitionType, ${timeRange.value}, layer: $layerIndex)';
  }
}

class TransitionFactory {
  static Transition createCrossfade({
    required TimeRange timeRange,
    Clip? sourceClip,
    Clip? targetClip,
    Curve curve = Curves.linear,
  }) {
    return Transition(
      transitionType: TransitionType.crossfade,
      timeRange: timeRange,
      curve: curve,
      sourceClip: sourceClip,
      targetClip: targetClip,
    );
  }
  
  static Transition createWipe({
    required TransitionType direction,
    required TimeRange timeRange,
    Clip? sourceClip,
    Clip? targetClip,
    Curve curve = Curves.linear,
  }) {
    assert([
      TransitionType.wipeLeft,
      TransitionType.wipeRight,
      TransitionType.wipeUp,
      TransitionType.wipeDown,
    ].contains(direction));
    
    return Transition(
      transitionType: direction,
      timeRange: timeRange,
      curve: curve,
      sourceClip: sourceClip,
      targetClip: targetClip,
      parameters: {
        'direction': direction,
      },
    );
  }
  
  static Transition createCustom({
    required TimeRange timeRange,
    required Map<String, dynamic> parameters,
    Clip? sourceClip,
    Clip? targetClip,
    Curve curve = Curves.linear,
  }) {
    return Transition(
      transitionType: TransitionType.custom,
      timeRange: timeRange,
      curve: curve,
      parameters: parameters,
      sourceClip: sourceClip,
      targetClip: targetClip,
    );
  }
}