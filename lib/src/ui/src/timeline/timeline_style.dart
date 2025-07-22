import 'package:flutter/material.dart';

typedef TextBuilder = Widget Function(BuildContext context, String text);

class FrameDragHandleStyle {
  final Color backgroundColor;
  final double width;
  final double height;
  final TextBuilder? textBuilder;
  final BorderRadius? borderRadius;

  const FrameDragHandleStyle({
    this.backgroundColor = Colors.purple,
    this.width = 75,
    this.height = 75,
    this.textBuilder,
    this.borderRadius,
  });

  FrameDragHandleStyle copyWith({
    Color? backgroundColor,
    double? width,
    double? height,
    TextBuilder? textBuilder,
    BorderRadius? borderRadius,
  }) {
    return FrameDragHandleStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      width: width ?? this.width,
      height: height ?? this.height,
      textBuilder: textBuilder ?? this.textBuilder,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  Widget buildDefaultText(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class TimelineStyle {
  final FrameDragHandleStyle frameDragHandleStyle;
  final KeyframeIconBuilder? keyframeIconBuilder;
  final KeyframeToggleIconBuilder? keyframeToggleIconBuilder;

  const TimelineStyle({
    this.frameDragHandleStyle = const FrameDragHandleStyle(),
    this.keyframeIconBuilder,
    this.keyframeToggleIconBuilder,
  });

  TimelineStyle copyWith({
    FrameDragHandleStyle? frameDragHandleStyle,
    KeyframeIconBuilder? keyframeIconBuilder,
    KeyframeToggleIconBuilder? keyframeToggleIconBuilder,
  }) {
    return TimelineStyle(
      frameDragHandleStyle: frameDragHandleStyle ?? this.frameDragHandleStyle,
      keyframeIconBuilder: keyframeIconBuilder ?? this.keyframeIconBuilder,
      keyframeToggleIconBuilder: keyframeToggleIconBuilder ?? this.keyframeToggleIconBuilder,
    );
  }
}

// Re-export the KeyframeIconBuilder typedef for convenience
typedef KeyframeIconBuilder = Widget Function(
  BuildContext context,
  bool isSelected,
  bool isHovered,
  int frameNumber,
);

typedef KeyframeToggleIconBuilder = Widget Function(
  BuildContext context,
  bool hasKeyframeAtCurrentFrame,
  VoidCallback onPressed,
);