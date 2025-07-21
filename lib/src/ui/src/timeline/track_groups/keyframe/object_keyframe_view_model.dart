// import 'package:flutter/foundation.dart';
// import 'package:mixreel_ui/mixreel_ui.dart';
// import 'package:mixreel_ui/src/viewmodels/src/scene/src/timeline/animation/animation_channel_view_model.dart';
// import 'package:mixreel_ui/src/viewmodels/src/scene/src/timeline/timeline_view_model.dart';

// abstract class ObjectKeyframeViewModel extends ChangeNotifier {
//   ValueListenable<List<int>> get frames;
//   ValueListenable<bool> get isSelected;
//   void select();
//   void deleteAll(int frameNumber);
//   void move(int toFrame);
// }

// class ObjectKeyframeViewModelImpl extends ObjectKeyframeViewModel {
  
//   final SceneObjectInstanceModel _model;
//   final AnimationChannelViewModel trackViewModel;

//   final ValueNotifier<Set<int>> _frameNumbers = ValueNotifier<Set<int>>({});
//   final ValueNotifier<Map<int, int>> _keyframeDensity =
//       ValueNotifier<Map<int, int>>({});

//   ObjectKeyframeViewModelImpl(this._model, this.trackViewModel) {
//     _model.translation.keyframes.addListener(_updateFrameNumbers);
//     _model.rotation.keyframes.addListener(_updateFrameNumbers);
//     _model.scale.keyframes.addListener(_updateFrameNumbers);
//     _updateFrameNumbers();
//   }

//   @override
//   void selectFrame(int frameNumber) {
//     _timelineController.selectAllKeyframesForFrame(frameNumber, [
//       this._model.translation,
//       this._model.rotation,
//       this._model.scale,
//     ]);
//   }

//   @override
//   void deleteKeyframesAtFrame(int frameNumber) {
//     final allKeyframes = _getKeyframesAtFrame(frameNumber);

//     for (final (track, keyframe) in allKeyframes) {
//       track.removeKeyframeAt(frameNumber);
//     }
//   }

//   @override
//   void moveKeyframesAtFrame(int fromFrame, int toFrame) {
//     final allKeyframes = _getKeyframesAtFrame(fromFrame);

//     for (final (track, keyframe) in allKeyframes) {
//       final value = keyframe.value;
//       track.removeKeyframeAt(fromFrame);
//       // track.addOrUpdateKeyframe(toFrame, value);
//     }
//   }

//   List<(AnimationTrack, Keyframe)> _getKeyframesAtFrame(
//     int frameNumber,
//   ) {
//     final List<(AnimationTrack, Keyframe)> keyframes = [];

//     for (final keyframe in _model.translation.keyframes.value) {
//       if (keyframe.frameNumber.value == frameNumber) {
//         keyframes.add((_model.translation, keyframe));
//       }
//     }

//     for (final keyframe in _model.rotation.keyframes.value) {
//       if (keyframe.frameNumber.value == frameNumber) {
//         keyframes.add((_model.rotation, keyframe));
//       }
//     }

//     for (final keyframe in _model.scale.keyframes.value) {
//       if (keyframe.frameNumber.value == frameNumber) {
//         keyframes.add((_model.scale, keyframe));
//       }
//     }

//     return keyframes;
//   }

//   @override
//   void dispose() {
//     _model.translation.keyframes.removeListener(_updateFrameNumbers);
//     _model.rotation.keyframes.removeListener(_updateFrameNumbers);
//     _model.scale.keyframes.removeListener(_updateFrameNumbers);
//     _frameNumbers.dispose();
//     _keyframeDensity.dispose();
//     super.dispose();
//   }
  
//   @override
//   void deleteAll(int frameNumber) {
//     // TODO: implement deleteAll
//   }
  
//   @override
//   // TODO: implement frameNumber
//   ValueListenable<int> get frameNumber => throw UnimplementedError();
  
//   @override
//   // TODO: implement isSelected
//   ValueListenable<bool> get isSelected => throw UnimplementedError();
  
//   @override
//   void move(int toFrame) {
//     // TODO: implement move
//   }
  
//   @override
//   void select() {
//     // TODO: implement select
//   }
// }
