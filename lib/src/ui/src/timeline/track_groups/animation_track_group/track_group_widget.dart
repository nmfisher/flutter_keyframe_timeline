import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyframe_timeline/src/model/model.dart';
import 'package:flutter_keyframe_timeline/src/timeline_controller.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/shared/expand_icon.dart';
import 'package:flutter_keyframe_timeline/src/ui/src/timeline/track_groups/animation_track_group/value_editor/animation_channel_editor_widget.dart';
import 'package:mix/mix.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TrackGroupWidget<V extends AnimationTrackGroup> extends StatelessWidget {
  final TimelineController<V> controller;
  final V group;

  final int index;

  const TrackGroupWidget({
    super.key,
    required this.group,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.active,
      builder: (_, active, __) {
        final isActive = active.contains(group);
        return ValueListenableBuilder(
          valueListenable: group.isVisible,
          builder: (_, isVisible, __) {
            return ValueListenableBuilder(
              valueListenable: group.isExpanded,
              builder: (_, isExpanded, __) {
                return VBox(
                  style: Style(
                    $flex.crossAxisAlignment.start(),
                    $box.color.white.withOpacity(0.5),
                    $box.border.only(
                      top: BorderSideDto(color: ColorDto(Colors.black)),
                    ),
                  ),
                  children: [
                    HBox(
                      // style: TimelineStyle.objectName,
                      children: [
                        Expanded(
                          child: Listener(
                            behavior: HitTestBehavior.translucent,
                            onPointerDown: (details) {
                              if (details.buttons & kPrimaryMouseButton ==
                                  kPrimaryMouseButton) {
                                controller.setActive(group, true);
                              }
                            },
                            child: HBox(
                              children: [
                                CustomExpandIcon(
                                  isExpanded: isExpanded,
                                  isActive: isActive,
                                  setExpanded: group.setExpanded,
                                ),
                                Expanded(
                                  child: ValueListenableBuilder(
                                    valueListenable: group.displayName,
                                    builder: (_, displayName, __) => StyledText(
                                      displayName,
                                      style: Style(
                                        // $text.style.ref($token.textStyle.label),
                                        // $text.style.color.ref($token.color.onSurface),
                                        $text.color.withOpacity(
                                          isActive || isExpanded ? 1.0 : 0.5,
                                        ),
                                        $text.overflow.ellipsis(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            group.setVisible(!isVisible);
                          },
                          child: Box(
                            child: Icon(
                              isVisible
                                  ? PhosphorIcons.checkSquare()
                                  : PhosphorIcons.square(),
                              size: 16,
                              color: Colors.white.withOpacity(
                                isActive || isExpanded ? 1.0 : 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isExpanded)
                      ...group.tracks
                          .map(
                            (track) => AnimationChannelEditorWidget(
                              track: track,
                              controller: controller,
                            ),
                          )
                          .cast<Widget>(),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
