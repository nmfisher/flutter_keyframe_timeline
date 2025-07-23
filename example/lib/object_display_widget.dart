import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyframe_timeline/flutter_keyframe_timeline.dart';
import 'package:flutter_keyframe_timeline_example/object/objects.dart';

class ObjectDisplayWidget extends StatefulWidget {
  final ObjectHolder objectHolder;
  final TimelineController timelineController;

  const ObjectDisplayWidget({
    super.key,
    required this.objectHolder,
    required this.timelineController,
  });

  @override
  State<ObjectDisplayWidget> createState() => _ObjectDisplayWidgetState();
}

class _ObjectDisplayWidgetState extends State<ObjectDisplayWidget> {
  RandomObject? _selectedObject;

  @override
  void initState() {
    super.initState();

    // Listen to active track object changes and sync canvas selection
    widget.timelineController.active.addListener(() {
      final activeObjects = widget.timelineController.active.value;
      if (activeObjects.isEmpty) {
        setState(() {
          _selectedObject = null;
        });
      } else {
        // Find the object corresponding to the first active track object
        final animatableObject = activeObjects.first;
        final activeObject = widget.objectHolder.objects.firstWhere(
          (obj) => obj.trackObject == animatableObject,
          orElse: () => widget.objectHolder.objects.first,
        );
        setState(() {
          _selectedObject = activeObject;
        });
      }
    });
  }

  @override
  void dispose() {
    widget.timelineController.active.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ...widget.objectHolder.objects.map((obj) {
          final isSelected = _selectedObject == obj;
          return ValueListenableBuilder(
            valueListenable: obj.isVisible,
            builder: (_, isVisible, __) {
              if (!isVisible) {
                return SizedBox.shrink();
              }
              return Positioned(
                left: obj.position.dx,
                top: obj.position.dy,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedObject = obj;
                    });
                    widget.timelineController.setActive(obj.trackObject, true);
                  },
                  onPanUpdate: (details) {
                    if (_selectedObject == obj) {
                      final isShiftPressed =
                          HardwareKeyboard.instance.isShiftPressed;

                      setState(() {
                        if (isShiftPressed) {
                          // Scale mode: use vertical drag to scale uniformly
                          final scaleChange =
                              -details.delta.dy *
                              0.01; // Negative for intuitive up=bigger
                          obj.scaleX = (obj.scaleX + scaleChange).clamp(
                            0.1,
                            5.0,
                          );
                          obj.scaleY = (obj.scaleY + scaleChange).clamp(
                            0.1,
                            5.0,
                          );
                        } else {
                          // Move mode: update position
                          obj.position = Offset(
                            obj.position.dx + details.delta.dx,
                            obj.position.dy + details.delta.dy,
                          );
                        }
                      });
                      widget.objectHolder.onUpdate.call();
                    }
                  },
                  child: Transform.rotate(
                    angle: obj.rotation,
                    child: Transform.scale(
                      scaleX: obj.scaleX,
                      scaleY: obj.scaleY,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: obj.color,
                          border: isSelected
                              ? Border.all(color: Colors.red, width: 3)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mouse Controls:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  '• Click to select object',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  '• Drag to move selected object',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  '• Shift+Drag to scale selected object',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 8),
                Text(
                  'Selection Sync:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  '• Selecting in timeline selects object',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  '• Selecting object selects timeline',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    widget.objectHolder.addNewObject();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    'Add New Object',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
