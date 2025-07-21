// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:mixreel_ui/src/models/src/keyframe_model.dart';
// import 'package:mixreel_ui/src/viewmodels/abstract_viewmodel.dart';
// import 'package:mixreel_ui/src/viewmodels/src/scene/src/timeline/animation/transform_channel_view_model.dart';

// abstract class KeyframeViewModel extends AbstractViewModelImpl {
//   ValueListenable<int> get frameNumber;
//   ValueListenable<Interpolation> get interpolation;
//   void setFrameNumber(int frameNumber);
//   ValueListenable<bool> get isSelected;
//   Future setSelected(bool selected);
//   Future delete();
// }

// class KeyframeViewModelImpl extends KeyframeViewModel {
//   ///
//   ///
//   ///
//   @override
//   ValueListenable<int> get frameNumber => model.frameNumber;

//   ///
//   ///
//   ///
//   @override
//   ValueListenable<Interpolation> get interpolation => model.interpolation;

//   ///
//   ///
//   ///
//   final Keyframe model;

//   ///
//   ///
//   ///
//   final AnimationChannelViewModel trackViewModel;

//   ///
//   ///
//   ///
//   @override
//   final ValueNotifier<bool> isSelected = ValueNotifier<bool>(false);

//   ///
//   ///
//   ///
//   KeyframeViewModelImpl(this.model, this.trackViewModel);

//   ///
//   ///
//   ///
//   @override
//   void setFrameNumber(int frameNumber) async {
//     await model.setFrameNumber(frameNumber);
//   }

//   ///
//   ///
//   ///
//   @override
//   Future setSelected(bool selected) async {
//     isSelected.value = selected;
//     trackViewModel.setKeyframeSelected(
//       this.model,
//       selected,
//       append: HardwareKeyboard.instance.isShiftPressed,
//     );
//   }

//   ///
//   ///
//   ///
//   @override
//   Future delete() async {
//     await trackViewModel.remove(model.frameNumber.value);
//   }

//   ///
//   ///
//   ///
//   @override
//   Future dispose() async {
//     await super.dispose();
//     this.isSelected.dispose();
//   }
// }
