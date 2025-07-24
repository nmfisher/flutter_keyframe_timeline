# Flutter Keyframe Timeline

A Flutter package for creating keyframe-based timelines for 2D/3D animations, video editing, etc.

### Core Concepts

An object (e.g. a video, or a polygon on a 2D canvas) may have various properties that can be animated over time (position, rotation, scale, etc). Each property can be assigned to an `AnimationTrack`  containing zero or more `Keyframes`. Each `Keyframe` represents the value for that track at a specified frame, and an interpolation method. An `AnimatableObject` is a collection of `AnimationTrack` that belong to an object. A channel refers to a single animatable values in  a track (e.g. a "translation" track has channels "x" and "y"). The generic parameter `ChannelValueType` indicates the type of this value. 

Currently supported channel value types:
- `ScalarChannelValueType`: Single numeric values
- `Vector2ChannelValueType`: 2D vectors (x, y)
- `Vector3ChannelValueType`: 3D vectors (x, y, z)
- `Vector4ChannelValueType`: 4D vectors (r, g, b, a)
- `QuaternionChannelValueType`: quaternion (x, y, z, w)

This package uses `ValueNotifier` to implement two-way data binding to synchronize the timeline UI and the actual underlying objects. For example, if you are animating objects on a 2D canvas, manipulating the timeline will update the position of the objects, and updating the position of the objects (e.g. by clicking and dragging on the canvas) will update the timeline.

### Getting Started

See the example app in `example`.

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_keyframe_timeline: ^0.0.1
```

There are three main interfaces you should be familiar with:

1) `TimelineWidget`

The main UI component that renders the interactive timeline. It displays track groups, keyframes, and provides controls for scrubbing through frames, zooming, and editing keyframes. Takes a `TimelineController` and optional `TimelineStyle` for customization.

2) `TimelineController`

The central controller that manages timeline state and coordinates between the UI and your data. While mostly internal, you'll need to listen to `controller.active` to sync selection between timeline and your objects (or call methods like `setActive()` when your objects are selected externally).

3) `TrackController`

An interface you must implement to bridge between the timeline and your data objects. It has two key methods:

- `getCurrentValue()`: Returns the current value of a track (e.g., object's position). Called when the timeline needs to read your object's current state.
- `applyValue()`: Updates your object when timeline values change (e.g., dragging keyframes). Called when the timeline modifies your object's properties.

### Keyboard Shortcuts

The timeline supports keyboard shortcuts:
- `Delete`: Delete selected keyframes
- `Left arrow`: Previous frame
- `Right arrow`: Next frame


## Contributing

Contributions are welcome.

## License

This project is licensed under the MIT License - see the LICENSE file for details.