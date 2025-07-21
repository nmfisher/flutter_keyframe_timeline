import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'keyframe_display_widget.dart';

class ObjectKeyframeWidget extends StatefulWidget {
  final List<Animation> model;
  final ValueListenable<int> pixelsPerFrame;

  const ObjectKeyframeWidget({
    super.key,
    required this.model,
    required this.pixelsPerFrame,
  });

  @override
  State<ObjectKeyframeWidget> createState() => _ObjectKeyframeWidgetState();
}

class _ObjectKeyframeWidgetState extends State<ObjectKeyframeWidget> {
  // late final ObjectKeyframeViewModel viewModel;

  @override
  void initState() {
    super.initState();
    // viewModel = ObjectKeyframeViewModelImpl(widget.model);
  }

  @override
  void dispose() {
    // viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
    // return ValueListenableBuilder(
    //   valueListenable: widget.pixelsPerFrame,
    //   builder:
    //       (_, pixelsPerFrame, __) => ValueListenableBuilder(
    //         valueListenable: viewModel.frameNumbers,
    //         builder:
    //             (_, frameNumbers, __) => ValueListenableBuilder(
    //               valueListenable: viewModel.keyframeDensity,
    //               builder:
    //                   (_, keyframeDensity, __) => Stack(
    //                     children:
    //                         frameNumbers.map((frameNumber) {
    //                           final density = keyframeDensity[frameNumber] ?? 1;
    //                           final isSelected = viewModel.isFrameSelected(
    //                             frameNumber,
    //                           );

    //                           return KeyframeDisplayWidget(
    //                             pixelsPerFrame: pixelsPerFrame.toDouble(),
    //                             frameNumber: frameNumber,
    //                             isSelected: isSelected,
    //                             onTap: () {
    //                               viewModel.selectFrame(frameNumber);
    //                             },
    //                             onDelete: () {
    //                               viewModel.deleteKeyframesAtFrame(frameNumber);
    //                             },
    //                             onFrameNumberChanged: (newFrame) {
    //                               viewModel.moveKeyframesAtFrame(
    //                                 frameNumber,
    //                                 newFrame,
    //                               );
    //                             },
    //                           );
    //                         }).toList(),
    //                   ),
    //             ),
    //       ),
    // );
  }
}
