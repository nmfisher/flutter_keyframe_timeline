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
  
  Widget _renderVideoFrame(VideoObject videoObj, int currentFrame) {
    // Clamp frame to available range
    final frameIndex = currentFrame.clamp(0, videoObj.pixelData.length - 1);
    final frameData = videoObj.pixelData[frameIndex];
    
    // Create a custom painter to render the grayscale pixel data
    return CustomPaint(
      painter: _VideoFramePainter(frameData),
      size: const Size(60, 60),
    );
  }

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
          (obj) => obj.animatableObject == animatableObject,
          orElse: () => widget.objectHolder.objects.first,
        );
        // Only select RandomObject instances (VideoObject doesn't have display properties)
        if (activeObject is RandomObject) {
          setState(() {
            _selectedObject = activeObject;
          });
        } else {
          setState(() {
            _selectedObject = null;
          });
        }
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
        // Random objects (existing functionality)
        ...widget.objectHolder.objects.map((obj) {
          final isSelected = _selectedObject == obj;
          
          // Only RandomObject has position and isVisible properties
          if (obj is! RandomObject) {
            return SizedBox.shrink();
          }
          
          return ValueListenableBuilder(
            valueListenable: obj.isVisible,
            builder: (_, isVisible, __) {
              if (isVisible == false) {
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
                    widget.timelineController.setActive(obj.animatableObject, true);
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
                          obj.setScaleX((obj.scaleX + scaleChange).clamp(
                            0.1,
                            5.0,
                          ));
                          obj.setScaleY((obj.scaleY + scaleChange).clamp(
                            0.1,
                            5.0,
                          ));
                          
                        } else {
                          // Move   : update position
                          obj.setPosition(Offset(
                            obj.position.dx + details.delta.dx,
                            obj.position.dy + details.delta.dy,
                          ));
                        
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
        
        // Video objects - display at bottom left in horizontal list with drag functionality
        Positioned(
          left: 10,
          bottom: 10,
          child: ValueListenableBuilder(
            valueListenable: widget.timelineController.currentFrame,
            builder: (_, currentFrame, __) {
              final videoObjects = widget.objectHolder.objects.whereType<VideoObject>().toList();
              
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: videoObjects.asMap().entries.map((entry) {
                  final index = entry.key;
                  final videoObj = entry.value;
                  final isSelected = widget.timelineController.active.value.contains(videoObj.animatableObject);
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Video frame preview
                        GestureDetector(
                          onTap: () {
                            widget.timelineController.setActive(videoObj.animatableObject, true);
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              border: isSelected
                                  ? Border.all(color: Colors.red, width: 3)
                                  : Border.all(color: Colors.grey, width: 1),
                            ),
                            child: _renderVideoFrame(videoObj, currentFrame),
                          ),
                        ),
                        SizedBox(height: 4),
                        // Video info and drag handle
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.red.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${videoObj.startFrame}-${videoObj.endFrame}',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 4),
                              GestureDetector(
                                onPanUpdate: (details) {
                                  // Drag horizontally to change start frame
                                  final pixelsPerFrame = widget.timelineController.pixelsPerFrame.value;
                                  final frameDelta = (details.delta.dx / pixelsPerFrame).round();
                                  if (frameDelta != 0) {
                                    final newStartFrame = (videoObj.startFrame + frameDelta).clamp(0, 1000);
                                    videoObj.setStartFrame(newStartFrame);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  child: Icon(
                                    Icons.drag_handle,
                                    size: 16,
                                    color: isSelected ? Colors.red : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
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

class _VideoFramePainter extends CustomPainter {
  final List<List<int>> frameData;
  
  _VideoFramePainter(this.frameData);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final pixelWidth = size.width / frameData.first.length;
    final pixelHeight = size.height / frameData.length;
    
    for (int y = 0; y < frameData.length; y++) {
      for (int x = 0; x < frameData[y].length; x++) {
        final grayValue = frameData[y][x];
        paint.color = Color.fromARGB(255, grayValue, grayValue, grayValue);
        canvas.drawRect(
          Rect.fromLTWH(x * pixelWidth, y * pixelHeight, pixelWidth, pixelHeight),
          paint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant _VideoFramePainter oldDelegate) {
    return oldDelegate.frameData != frameData;
  }
}
