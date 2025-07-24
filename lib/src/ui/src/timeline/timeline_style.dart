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

typedef TrackObjectExtraWidgetBuilder = Widget Function(
  BuildContext context,
  AnimatableObject object,
  bool trackObjectIsActive,
  bool trackObjectIsExpanded
);

typedef ChannelValueTextFieldWidgetBuilder = Widget Function(
  BuildContext context,
  Widget textField,
  String dimensionLabel,
  int dimensionIndex,
);

class TrackObjectNameStyle {
  final Color textColor;
  final IconData iconData;
  final Color iconColor;
  final Color borderColor;

  const TrackObjectNameStyle({
    this.textColor = Colors.black,
    this.iconData = Icons.expand_more,
    this.iconColor = Colors.black,
    this.borderColor = Colors.black,
  });

  TrackObjectNameStyle copyWith({
    Color? textColor,
    IconData? iconData,
    Color? iconColor,
    Color? borderColor,
  }) {
    return TrackObjectNameStyle(
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

class ChannelValueEditorStyle {
  final Color textColor;
  final double fontSize;
  final double width;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? enabledBorderColor;
  final Color? errorBorderColor;
  final Color? labelTextColor;
  final InputDecoration? inputDecoration;

  const ChannelValueEditorStyle({
    this.textColor = Colors.black,
    this.fontSize = 11.0,
    this.width = 52.0,
    this.backgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.enabledBorderColor,
    this.errorBorderColor,
    this.labelTextColor,
    this.inputDecoration,
  });

  ChannelValueEditorStyle copyWith({
    Color? textColor,
    double? fontSize,
    double? width,
    Color? backgroundColor,
    Color? borderColor,
    Color? focusedBorderColor,
    Color? enabledBorderColor,
    Color? errorBorderColor,
    Color? labelTextColor,
    InputDecoration? inputDecoration,
  }) {
    return ChannelValueEditorStyle(
      textColor: textColor ?? this.textColor,
      fontSize: fontSize ?? this.fontSize,
      width: width ?? this.width,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
      enabledBorderColor: enabledBorderColor ?? this.enabledBorderColor,
      errorBorderColor: errorBorderColor ?? this.errorBorderColor,
      labelTextColor: labelTextColor ?? this.labelTextColor,
      inputDecoration: inputDecoration ?? this.inputDecoration,
    );
  }
}