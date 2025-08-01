class TimeRange {
  final int startFrame;
  final int endFrame;

  const TimeRange({
    required this.startFrame,
    required this.endFrame,
  });

  int get duration => endFrame - startFrame;

  bool get isEmpty => duration <= 0;

  bool contains(int frame) {
    return frame >= startFrame && frame < endFrame;
  }

  bool overlaps(TimeRange other) {
    return startFrame < other.endFrame && endFrame > other.startFrame;
  }

  TimeRange? intersection(TimeRange other) {
    final start = startFrame > other.startFrame ? startFrame : other.startFrame;
    final end = endFrame < other.endFrame ? endFrame : other.endFrame;
    
    if (start >= end) {
      return null;
    }
    
    return TimeRange(startFrame: start, endFrame: end);
  }

  TimeRange union(TimeRange other) {
    final start = startFrame < other.startFrame ? startFrame : other.startFrame;
    final end = endFrame > other.endFrame ? endFrame : other.endFrame;
    
    return TimeRange(startFrame: start, endFrame: end);
  }

  TimeRange shifted(int frameOffset) {
    return TimeRange(
      startFrame: startFrame + frameOffset,
      endFrame: endFrame + frameOffset,
    );
  }

  TimeRange trimmed({int? newStart, int? newEnd}) {
    return TimeRange(
      startFrame: newStart ?? startFrame,
      endFrame: newEnd ?? endFrame,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeRange &&
        other.startFrame == startFrame &&
        other.endFrame == endFrame;
  }

  @override
  int get hashCode => startFrame.hashCode ^ endFrame.hashCode;

  @override
  String toString() => 'TimeRange($startFrame-$endFrame)';
}