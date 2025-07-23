import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';

typedef TextBuilder = Widget Function(BuildContext context, String text);

class FrameDragHandleStyle {
  final Color backgroundColor;
  final double width;
  final double height;
  final TextBuilder? textBuilder;
  final BorderRadius? borderRadius;

  const FrameDragHandleStyle({
    this.backgroundColor = Colors.purple,
    this.width = 50,
    this.height = 25,
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

typedef TrackGroupExtraWidgetBuilder = Widget Function(
  BuildContext context,
  AnimationTrackGroup group,
  bool trackGroupIsActive,
  bool trackGroupIsExpanded
);

class TrackGroupNameStyle {
  final Color textColor;
  final IconData iconData;
  final Color iconColor;
  final Color borderColor;

  const TrackGroupNameStyle({
    this.textColor = Colors.black,
    required this.iconData,
    this.iconColor = Colors.black,
    this.borderColor = Colors.black,
  });

  TrackGroupNameStyle copyWith({
    Color? textColor,
    IconData? iconData,
    Color? iconColor,
    Color? borderColor,
  }) {
    return TrackGroupNameStyle(
      textColor: textColor ?? this.textColor,
      iconData: iconData ?? this.iconData,
      iconColor: iconColor ?? this.iconColor,
      borderColor: borderColor ?? this.borderColor,
    );
  }
}

class TimelineBackgroundStyle {
  final Color majorTickColor;
  final Color minorTickColor;
  final Color textColor;
  final int minorTickInterval;
  final int majorTickInterval;
  final double textFontSize;

  const TimelineBackgroundStyle({
    this.majorTickColor = Colors.black,
    this.minorTickColor = Colors.grey,
    this.textColor = Colors.black,
    this.minorTickInterval = 10,
    this.majorTickInterval = 60,
    this.textFontSize = 10.0,
  });

  TimelineBackgroundStyle copyWith({
    Color? majorTickColor,
    Color? minorTickColor,
    Color? textColor,
    int? minorTickInterval,
    int? majorTickInterval,
    double? textFontSize,
  }) {
    return TimelineBackgroundStyle(
      majorTickColor: majorTickColor ?? this.majorTickColor,
      minorTickColor: minorTickColor ?? this.minorTickColor,
      textColor: textColor ?? this.textColor,
      minorTickInterval: minorTickInterval ?? this.minorTickInterval,
      majorTickInterval: majorTickInterval ?? this.majorTickInterval,
      textFontSize: textFontSize ?? this.textFontSize,
    );
  }
}