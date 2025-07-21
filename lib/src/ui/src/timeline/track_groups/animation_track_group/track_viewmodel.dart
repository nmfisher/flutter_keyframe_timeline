// import 'package:flutter/foundation.dart';
// import 'package:flutter_keyframe_timeline/src/model/src/animation_track.dart';
// import 'package:flutter_keyframe_timeline/src/model/src/animation_track_group.dart';
// import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';

// abstract class AnimationTrackViewModel {
//   ValueListenable<String> get displayName;
//   ValueListenable<bool> get isExpanded;
//   ValueListenable<bool> get isSelected;
//   ValueListenable<bool> get visible;

//   void setIsExpanded(bool isExpanded);
//   void setVisible(bool visible);

//   void addKeyframeForCurrentFrame(AnimationTrack track);

//   void setSelected();

//   Future dispose();
// }

// class TrackGroupViewModelImpl extends TrackGroupViewModel {
//   final TimelineController timelineController;

//   @override
//   ValueListenable<String> get displayName => group.displayName;

//   @override
//   ValueNotifier<bool> isExpanded = ValueNotifier<bool>(false);

//   @override
//   ValueNotifier<bool> get isSelected => ValueNotifier<bool>(false);

//   final AnimationTrackGroup group;

//   TrackGroupViewModelImpl(this.group, this.timelineController) {
//     timelineController.expanded.addListener(_onExpandedChange);
//   }

//   void _onExpandedChange() {
//     if (timelineController.expanded.value.contains(model)) {
//       if (!this.isExpanded.value) {
//         this.isExpanded.value = true;
//       }
//     } else {
//       if (this.isExpanded.value) {
//         this.isExpanded.value = false;
//       }
//     }
//   }

//   @override
//   void addKeyframeForCurrentFrame() async {
//     switch (channel) {
//       case TranslationChannel():
//         model.translation.addOrUpdateKeyframe(
//           timelineController.currentFrame.value,
//           channel.convertOrDefault(model.currentPosition.value),
//         );
//         break;
//       case RotationChannel():
//         model.rotation.addOrUpdateKeyframe(
//           timelineController.currentFrame.value,
//           channel.convertOrDefault(model.currentRotation.value),
//         );
//         break;
//       case ScaleChannel():
//         model.scale.addOrUpdateKeyframe(
//           timelineController.currentFrame.value,
//           channel.convertOrDefault(model.currentScale.value),
//         );
//         break;
//       default:
//         throw UnimplementedError();
//     }
//   }

//   @override
//   Future<void> dispose() async {
//     timelineController.expanded.removeListener(_onExpandedChange);
//     isExpanded.dispose();
//   }

//   @override
//   void setIsExpanded(bool isExpanded) async {
//     timelineController.setExpanded(this.group, isExpanded);
//   }

//   @override
//   void setVisible(bool visible) async {
//     await model.setVisible(visible);
//     App.instance.setVisibility(model, visible);
//   }

//   @override
//   ValueListenable<bool> get visible => group.visible;

//   void setSelected() {
//     App.instance.select(this.model);
//   }
// }
