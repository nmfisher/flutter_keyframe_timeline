# Flutter Keyframe Timeline

A Flutter package for creating keyframe-based timelines for 2D/3D animations, video editing, etc.

![timeline](https://github.com/user-attachments/assets/4c3a33de-4693-4485-a7f3-cd5a27e4bb7e)

### Core Concepts

`AnimatableObject` represents any object that can be animated over time (e.g. a video clip, a 2D shape, 3D asset etc).  An `AnimatableObject` exposes at least one `AnimationTrack`, representing the actual property of the object that should be animated (its position, opacity, color, etc).  `ChannelValueType` represents the *type* of the value of the AnimationTrack that is being animated (a scalar double, Vector3, etc etc).  

An `AnimationTrack` will contain zero or more `Keyframes`. Each `Keyframe` represents the value for that track at a specified frame, and an interpolation method. 

Currently supported channel value types:
- `ScalarChannelValueType`: Single numeric values
- `Vector2ChannelValueType`: 2D vectors (x, y)
- `Vector3ChannelValueType`: 3D vectors (x, y, z)
- `Vector4ChannelValueType`: 4D vectors (r, g, b, a)
- `QuaternionChannelValueType`: quaternion (x, y, z, w)

`TimelineWidget` is the UI component that renders the interactive timeline. It displays track groups, keyframes, and provides controls for scrubbing through frames, zooming the timeline, and selecting/moving/deleting keyframes. The `TimelineWidget` constructor exposes arguments for various styles for the timeline components (frame dragger, timeline background ticks, object list and icons, etc).

When constructing a `TimelineWidget`, you must provide a `TimelineController`. This manages the state of the timeline and exposes various methods/listenables that you can use to synchronize the UI with your data. You can also use this to programatically control the current frame/list of active objects/etc, but this generally won't be necessary. 

To construct a `TimelineController`, you will need to pass a list of `AnimatableObject`. The easiest way to do so is to construct instances of `AnimatableObjectImpl` and `AnimationTrackImpl` from the model you use for your app.

e.g.

```
class MyModel {
  ValueListenable<double> get x;
  ValueListenable<double> get y;
  ValueListenable<double> get z;
  final String modelId;

  void setX(double x) {
    //
  }

  void setY(double y) {
    // 
  }

  void setZ(double z) {
    //
  }
}

TimelineController createTimelineController(List<MyModel> models) {

  final objects = <AnimatableObject>[];
  for(final model in models) {
    final positionTrack = AnimationTrackImpl<Vector3ChannelValueType>(
        keyframes:[],
        labels:["x", "y", "z"],
        label:"position"
    );

    positionTrack.setValue()
   
    final object = AnimatableObjectImpl(
      tracks:[
        positionTrack
      ],
      name: model.name
    );
    objects.add(object);
  }
  return TimelineController.create(objects);
 }
```

With this approach, the values manipulated in the timeline and the values in your original model are kept separate; you would need to add listeners to update one when the other updates, and vice versa. This package uses `ValueNotifier`/`ValueListenable` are used to implement two-way data binding to synchronize the timeline UI and the actual underlying objects. 

```


TimelineController createTimelineController(List<MyModel> models) {

  final objects = <AnimatableObject>[];
  for(final model in models) {
    final positionTrack = AnimationTrackImpl<Vector3ChannelValueType>(
        keyframes:[],
        labels:["x", "y", "z"],
        label:"position"
    );
    positionTrack.value.addListener(() {
      var unwrapped = positionTrack.value.value.unwrap();
      model.setX(unwrapped[0]);
      model.setY(unwrapped[1]);
      model.setZ(unwrapped[2]);
    });

    // make sure you dispose of this listener properly when it's no longer needed
    Listenable.merge([model.x, model.y, model.z]).addListener(() {
      positionTrack.setValue(
        Vector3ChannelValueType(
          Vector3(model.x.value,model.y.value,model.z.value)
        )
      );
    });
    
    final object =  AnimatableObjectImpl(
      tracks:[
        positionTrack
      ],
      name: model.name
    );
    objects.add(object);
  }
  return TimelineController.create(objects);
 }
```

We suggest adding a listener to the `active` property to manually toggle  selection between timeline and your objects (or call methods like `setActive()` when your objects are selected externally).










### Keyboard Shortcuts

The timeline supports keyboard shortcuts:
- `Delete`: Delete selected keyframes
- `Left arrow`: Previous frame
- `Right arrow`: Next frame

## Contributing

Contributions are welcome.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
