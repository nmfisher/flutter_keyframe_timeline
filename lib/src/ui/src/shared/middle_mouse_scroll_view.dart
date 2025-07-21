import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MiddleMouseScrollView extends StatefulWidget {
  final List<Widget> slivers;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final HitTestBehavior hitTestBehavior;
  final Clip clipBehavior;

  const MiddleMouseScrollView({
    super.key,
    required this.slivers,
    this.controller,
    this.physics,
    required this.scrollDirection,
    required this.hitTestBehavior,
    required this.clipBehavior,
  });

  @override
  State<MiddleMouseScrollView> createState() => _MiddleMouseScrollViewState();
}

class _MiddleMouseScrollViewState extends State<MiddleMouseScrollView> {
  bool _isMiddleMousePressed = false;
  late ScrollController _scrollController;
  Offset? _lastMousePosition;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _handleMiddleMouseScroll(PointerSignalEvent event) {
    if (!_isMiddleMousePressed) return;

    if (event is PointerScrollEvent) {
      final delta = widget.scrollDirection == Axis.vertical
          ? event.scrollDelta.dy
          : event.scrollDelta.dx;
      
      _scrollController.position.moveTo(
        _scrollController.position.pixels + delta,
        clamp: true,
      );
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_isMiddleMousePressed || _lastMousePosition == null) return;

    final delta = event.position - _lastMousePosition!;
    final scrollDelta = widget.scrollDirection == Axis.vertical
        ? -delta.dy
        : -delta.dx;
    
    _scrollController.position.moveTo(
      _scrollController.position.pixels + scrollDelta,
      clamp: true,
    );
    
    _lastMousePosition = event.position;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        if (event.buttons & kMiddleMouseButton != 0) {
          setState(() {
            _isMiddleMousePressed = true;
            _lastMousePosition = event.position;
          });
        }
      },
      onPointerUp: (PointerUpEvent event) {
        setState(() {
          _isMiddleMousePressed = false;
          _lastMousePosition = null;
        });
      },
      onPointerMove: _handlePointerMove,
      onPointerSignal: _handleMiddleMouseScroll,
      behavior: widget.hitTestBehavior,
      child: CustomScrollView(
        hitTestBehavior: widget.hitTestBehavior,
        scrollDirection: widget.scrollDirection,
        clipBehavior: widget.clipBehavior,
        controller: _scrollController,
        physics: widget.physics ?? const NeverScrollableScrollPhysics(),
        slivers: widget.slivers,
      ),
    );
  }
}