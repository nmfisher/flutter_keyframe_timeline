import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';
import 'package:mix/mix.dart';

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

typedef KeyframeIconBuilder = Widget Function(
  BuildContext context,
  bool isSelected,
  bool isHovered,
  int frameNumber,
);

Widget kDefaultKeyframeIconBuilder(
    BuildContext context, bool isSelected, bool isHovered, int frameNumber) {
  return Container(
    width: 24,
    height: 24,
    decoration: BoxDecoration(
      color: isSelected ? Colors.amber.withOpacity(0.2) : Colors.black,
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
          border: Border.all(width: isHovered || isSelected ? 2 : 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 2,
                  ),
                ]
              : null,
        ),
      ),
    ),
  );
}

typedef KeyframeToggleIconBuilder = Widget Function(
  BuildContext context,
  bool hasKeyframeAtCurrentFrame,
  VoidCallback onPressed,
);

Widget kDefaultKeyframeToggleIconBuilder(BuildContext context,
    bool hasKeyframeAtCurrentFrame, VoidCallback onPressed) {
  return IconButton(
    onPressed: onPressed,
    icon: Transform.rotate(
      angle: 0.785398, // 45 degrees in radians (pi/4) for diamond shape
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: hasKeyframeAtCurrentFrame
              ? Colors.blue
              : Colors.grey.withValues(alpha: 0.2),
          border: Border.all(
            color: hasKeyframeAtCurrentFrame
                ? Colors.black
                : Colors.grey.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
    ),
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
  );
}

typedef TrackObjectExtraWidgetBuilder = Widget Function(
    BuildContext context,
    TimelineObject object,
    bool trackObjectIsActive,
    bool trackObjectIsExpanded);

typedef ChannelValueTextFieldWidgetBuilder = Widget Function(
  BuildContext context,
  Widget textField,
  TextEditingController controller,
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
  final Color textFieldFontColor;
  final double textFieldFontSize;
  final double width;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? enabledBorderColor;
  final Color? errorBorderColor;
  final Widget Function(String label) labelBuilder;
  final InputDecoration? inputDecoration;

  static Widget buildLabel(String label) => StyledText(label,
      style: Style(
        $text.color.black(),
        $text.fontSize(10.0),
      ));

  const ChannelValueEditorStyle({
    this.textFieldFontColor = Colors.black,
    this.textFieldFontSize = 11.0,
    this.width = 52.0,
    this.backgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.enabledBorderColor,
    this.errorBorderColor,
    this.labelBuilder = buildLabel,
    this.inputDecoration,
  });

  ChannelValueEditorStyle copyWith({
    Color? textFieldFontColor,
    double? textFieldFontSize,
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
      textFieldFontColor: textFieldFontColor ?? this.textFieldFontColor,
      textFieldFontSize: textFieldFontSize ?? this.textFieldFontSize,
      width: width ?? this.width,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
      enabledBorderColor: enabledBorderColor ?? this.enabledBorderColor,
      errorBorderColor: errorBorderColor ?? this.errorBorderColor,
      inputDecoration: inputDecoration ?? this.inputDecoration,
    );
  }
}
