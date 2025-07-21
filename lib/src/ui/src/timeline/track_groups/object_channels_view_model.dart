import 'package:flutter/foundation.dart';
import 'package:flutter_keyframe_timeline/src/model/model.dart';
import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';
import 'package:vector_math/vector_math_64.dart';

abstract class ObjectChannelsViewModel {
  Future dispose();

  double get maxFrame => 1000.0;

  ///
  void setSelected(
    Keyframe<ChannelValueType> model,
    bool selected, {
    bool append = false,
  });

  ///
  Future selectKeyframe(Keyframe keyframe, {bool append = false}) async {
    throw Exception();
  }

  ///
  Future deselectKeyframe(Keyframe keyframe) async {
    throw Exception();
  }

  ///
  Future deleteKeyframe(Keyframe keyframe) {
    throw Exception();
  }

  ///
  ValueListenable<bool> get allSelected;

  ///
  void selectFrame(int frame);

  ///
  void deselectFrame();

  ///
  ValueListenable<Set<Keyframe<ChannelValueType>>> get selected;

  ///
  Iterable<int> get keyedFrames;
}

class ObjectChannelsViewModelImpl<V> extends ObjectChannelsViewModel {
  final V model;
  final List<AnimationTrack> tracks;
  ObjectChannelsViewModelImpl(this.model, this.tracks) {
    for (final track in this.tracks) {
      track.keyframes.addListener(_onKeyframesUpdated);
    }
  }

  void _onKeyframesUpdated() {
    final toRemove = <Keyframe>{};
    for (final key in selected.value) {
      for (final track in this.tracks) {
        if (tracks.every(
              (track) => track.hasKeyframeAt(key.frameNumber.value),
            ) ==
            true)
          toRemove.add(key);
      }
    }

    selected.value.removeAll(toRemove);
    selected.notifyListeners();
  }

  @override
  Future dispose() async {
    for (final track in tracks) {
      track.keyframes.removeListener(_onKeyframesUpdated);
    }
  }

  @override
  Iterable<int> get keyedFrames => tracks.expand((track) => track.keyedFrames);

  @override
  final ValueNotifier<Set<Keyframe<ChannelValueType>>> selected =
      ValueNotifier<Set<Keyframe<ChannelValueType>>>({});

  @override
  final ValueNotifier<bool> allSelected = ValueNotifier<bool>(false);

  @override
  void setSelected(
    Keyframe<ChannelValueType> model,
    bool selected, {
    bool append = false,
  }) {
    if (!append) {
      this.selected.value.clear();
    }
    if (selected) {
      this.selected.value.add(model);
    } else {
      this.selected.value.remove(model);
    }
    this.selected.notifyListeners();
  }

  @override
  void selectFrame(int frame) {
    deselectFrame(notify: false);

    bool allSelected = true;
    for (final track in tracks) {
      final keyframe = track.keyframeAt(frame);
      if(keyframe != null) {
          this.selected.value.add(keyframe);
      } else {
        allSelected = false;
      }
    }
    this.selected.notifyListeners();

    this.allSelected.value = allSelected;
  }

  @override
  void deselectFrame({bool notify = true}) {
    if (notify) {
      selected.notifyListeners();
    }
  }
}
