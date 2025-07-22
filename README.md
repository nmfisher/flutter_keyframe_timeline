# Flutter Keyframe Timeline

A Flutter package for creating interactive keyframe-based timelines for animations and video editing applications. This package provides a professional timeline widget with customizable styling, keyframe management, frame scrubbing capabilities, and robust two-way data binding.

## Core Concepts

Understanding the key concepts is essential for effectively using this timeline package:

### AnimationTrack
An **AnimationTrack** represents a single animatable property of an object, such as position, rotation, or scale. Each track contains:
- A collection of **keyframes** that define values at specific time points
- **Dimension labels** (e.g., ["x", "y"] for position, ["rads"] for rotation)
- A **track label** for display purposes
- **Generic type support** for different value types (scalar, vector2, vector4)

```dart
// Example from example/lib/main.dart
late final positionTrack = AnimationTrackImpl(
  <Keyframe<Vector2ChannelValueType>>[],  // Empty keyframes list initially
  ["x", "y"],                              // Two dimensions: x and y
  "position",                              // Display label
);
```

### Keyframe
A **Keyframe** stores a specific value at a particular frame number. It contains:
- **Frame number**: When this keyframe occurs in the timeline
- **Value**: The actual data (position, rotation, etc.) at that frame
- **Interpolation data**: How to blend between keyframes

Keyframes are the fundamental building blocks that define how properties change over time.

### AnimationTrackGroup
An **AnimationTrackGroup** is a collection of related **AnimationTracks** that belong to a single object or entity. This creates a hierarchical structure where:
- Each object has one **AnimationTrackGroup**
- Each **AnimationTrackGroup** contains multiple **AnimationTracks** (position, rotation, scale, color, etc.)
- The group provides a **display name** for the object in the timeline

```dart
// Example from example/lib/main.dart
late final AnimationTrackGroupImpl trackGroup;

RandomObject({...}) {
  trackGroup = AnimationTrackGroupImpl([
    positionTrack,    // Track for x, y position
    rotationTrack,    // Track for rotation in radians
    scaleTrack,       // Track for x, y scale factors
    colorTrack,       // Track for r, g, b, a color values
  ], name);           // Object name displayed in timeline
}
```

### Two-Way Data Binding

The timeline implements **bidirectional data synchronization** between the timeline UI and your application objects. This ensures that changes in either direction are automatically reflected:

#### Timeline → Object (User edits in timeline)
When users interact with the timeline (drag keyframes, edit values in `AnimationChannelEditorWidget`, add/remove keyframes), the changes must be applied to your actual objects:

```dart
// From ObjectHolder.applyValue() in example/lib/main.dart
@override
void applyValue<U extends ChannelValueType>(
  AnimationTrackGroup group,
  AnimationTrack<U> track,
  List<num> values,
) {
  var object = _lookup[group];
  object!.applyValue(track, values);  // Update the actual object properties
  onUpdate.call();                   // Trigger UI rebuild to show changes
}
```

#### Object → Timeline (External changes to object)
When your application code modifies object properties externally, the timeline must reflect these changes. This is achieved through **ValueListenable** reactive programming:

```dart
// From ObjectHolder.getCurrentValue() in example/lib/main.dart
@override
U getCurrentValue<U extends ChannelValueType>(
  AnimationTrackGroup group,
  AnimationTrack<U> track,
) {
  final object = _lookup[group]!;
  if (track == object.positionTrack) {
    return Vector2ChannelValueType(
      Vector2(object.position.dx, object.position.dy),  // Read current object state
    ) as U;
  }
  // ... handle other track types
}
```

#### Why ValueListenable?
The package uses **ValueListenable** throughout its architecture because:

1. **Automatic Updates**: When keyframe values change, all dependent UI components automatically rebuild
2. **Performance**: Only affected widgets rebuild, not the entire timeline
3. **Consistency**: Ensures the timeline always displays current data
4. **Reactive Architecture**: Changes flow naturally through the widget tree

Key ValueListenable properties include:
- `controller.currentFrame` - Current timeline position
- `controller.selected` - Currently selected keyframes  
- `controller.trackGroups` - List of all track groups
- `keyframe.frameNumber` - Individual keyframe positions
- Individual track values and keyframe collections

This reactive system ensures that when you edit a value in the `AnimationChannelEditorWidget` (the numeric input fields), the change immediately:
1. Updates the keyframe value
2. Triggers `applyValue()` to update your object
3. Notifies listeners via ValueListenable
4. Causes the timeline UI to rebuild and reflect the change

## Features

- **Interactive Timeline**: Drag and drop keyframes, scrub through frames, and manage animation tracks
- **Customizable Styling**: Fully customizable keyframe icons, frame drag handles, and timeline appearance  
- **Multi-Track Support**: Support for multiple animation tracks per object with expandable track groups
- **Frame Management**: Add, delete, and modify keyframes with context menus and keyboard shortcuts
- **Zoom Controls**: Built-in zoom functionality for precise timeline editing
- **Responsive Design**: Adapts to different screen sizes and orientations
- **Two-Way Data Binding**: Seamless synchronization between timeline and application data

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_keyframe_timeline: ^0.0.1
```

## Basic Usage

### 1. Create Your Data Model

First, create your animation objects and tracks:

```dart
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';

class AnimatedObject {
  final String name;
  late Offset position;
  late double rotation;
  late double scaleX;
  late double scaleY;

  late final positionTrack = AnimationTrackImpl(
    <Keyframe<Vector2ChannelValueType>>[],
    ["x", "y"],
    "position",
  );
  
  late final rotationTrack = AnimationTrackImpl(
    <Keyframe<ScalarChannelValueType>>[],
    ["rotation"],
    "rotation",
  );

  late final AnimationTrackGroupImpl trackGroup;

  AnimatedObject({required this.name, required this.position, required this.rotation}) {
    trackGroup = AnimationTrackGroupImpl([positionTrack, rotationTrack], name);
  }
}
```

### 2. Implement ValueBridge Interface

Create a bridge between your data and the timeline:

```dart
class ObjectHolder implements ValueBridge {
  final List<AnimatedObject> objects;
  final Function() onUpdate;

  ObjectHolder(this.objects, this.onUpdate);

  @override
  U getCurrentValue<U extends ChannelValueType>(
    AnimationTrackGroup group,
    AnimationTrack<U> track,
  ) {
    // Return current values from your objects
    final object = _findObjectByGroup(group);
    if (track == object.positionTrack) {
      return Vector2ChannelValueType(
        Vector2(object.position.dx, object.position.dy),
      ) as U;
    }
    // Handle other track types...
  }

  @override
  void applyValue<U extends ChannelValueType>(
    AnimationTrackGroup group,
    AnimationTrack<U> track,
    List<num> values,
  ) {
    // Apply values to your objects
    final object = _findObjectByGroup(group);
    if (track == object.positionTrack) {
      object.position = Offset(values[0].toDouble(), values[1].toDouble());
      onUpdate();
    }
    // Handle other track types...
  }
}
```

### 3. Create the Timeline Widget

```dart
class TimelineExample extends StatefulWidget {
  @override
  _TimelineExampleState createState() => _TimelineExampleState();
}

class _TimelineExampleState extends State<TimelineExample> {
  late ObjectHolder objectHolder;
  late TimelineController controller;

  @override
  void initState() {
    super.initState();
    
    // Create your animated objects
    final objects = [
      AnimatedObject(name: "Object 1", position: Offset(50, 50), rotation: 0.0),
      AnimatedObject(name: "Object 2", position: Offset(100, 100), rotation: 0.5),
    ];
    
    objectHolder = ObjectHolder(objects, () => setState(() {}));
    controller = TimelineControllerImpl(
      objects.map((o) => o.trackGroup).toList(),
      objectHolder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TimelineWidget(
        controller: controller,
      ),
    );
  }
}
```

## Customization

### Custom Keyframe Icons

You can customize the appearance of keyframe icons:

```dart
TimelineWidget(
  controller: controller,
  style: TimelineStyle(
    keyframeIconBuilder: (context, isSelected, isHovered, frameNumber) {
      return Transform.translate(
        offset: const Offset(-8, 0.0),
        child: Container(
          padding: EdgeInsets.all(4),
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              boxShadow: isSelected ? [
                BoxShadow(
                  color: Colors.orange,
                  spreadRadius: 3,
                  blurRadius: 6,
                ),
              ] : null,
            ),
            child: Transform.rotate(
              angle: 0.785398, // 45 degrees for diamond shape
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  border: Border.all(color: Colors.black, width: 1),
                ),
              ),
            ),
          ),
        ),
      );
    },
  ),
)
```

### Custom Frame Drag Handle

Customize the frame scrubber handle:

```dart
TimelineWidget(
  controller: controller,
  style: TimelineStyle(
    frameDragHandleStyle: FrameDragHandleStyle(
      backgroundColor: Color(0xFF333333),
      width: 50.0,
      height: 30.0,
      textBuilder: (context, text) => Text(
        text,
        style: TextStyle(
          color: Color(0xFFEEEEEE),
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  ),
)
```

## Advanced Features

### Zoom Controls

Add zoom functionality to your timeline:

```dart
Stack(
  children: [
    TimelineWidget(controller: controller),
    Positioned(
      top: 10,
      left: 10,
      child: TimelineZoomControl(timelineController: controller),
    ),
  ],
)
```

### Keyboard Shortcuts

The timeline supports keyboard shortcuts:
- `Delete`: Delete selected keyframes
- `Escape`: Clear selection

### Context Menus

Right-click on keyframes to access context menus for additional actions.

## API Reference

### TimelineController

The main controller for managing timeline state:

```dart
// Navigate to specific frame
controller.setCurrentFrame(30);

// Get current frame
int currentFrame = controller.currentFrame.value;

// Set pixels per frame (zoom level)
controller.setPixelsPerFrame(10);

// Manage selection
controller.setSelected([keyframe1, keyframe2], true);

// Expand/collapse track groups
controller.setExpanded(trackGroup, true);
```

### TimelineStyle

Customize the appearance of timeline components:

```dart
TimelineStyle(
  keyframeIconBuilder: (context, isSelected, isHovered, frameNumber) => Widget,
  frameDragHandleStyle: FrameDragHandleStyle(
    backgroundColor: Color,
    width: double,
    height: double,
    textBuilder: (context, text) => Widget,
  ),
)
```

### Animation Track Types

Supported channel value types:
- `ScalarChannelValueType`: Single numeric values
- `Vector2ChannelValueType`: 2D vectors (x, y)
- `Vector4ChannelValueType`: 4D vectors (r, g, b, a)

## Example

See the `/example` folder for a complete working example with animated objects that demonstrate:
- Multiple track groups with position, rotation, and scale tracks
- Custom keyframe icons with diamond shapes
- Interactive frame scrubbing
- Zoom controls
- Object animation playback

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.