import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FastDragWrapper extends StatefulWidget {
  /// The child widget to wrap with fast drag functionality
  final Widget child;

  /// Callback when drag ends and tab should change
  final Function(int direction)? onDragComplete;

  /// Whether to enable drag functionality
  final bool enabled;

  /// Sensitivity for drag detection (lower = more sensitive)
  final double sensitivity;

  /// Minimum velocity to trigger tab change
  final double velocityThreshold;

  /// Whether to add subtle visual feedback
  final bool showFeedback;

  const FastDragWrapper({
    Key? key,
    required this.child,
    this.onDragComplete,
    this.enabled = true,
    this.sensitivity = 50.0, // Distance in pixels
    this.velocityThreshold = 300.0, // Much lower for faster response
    this.showFeedback = true,
  }) : super(key: key);

  @override
  _FastDragWrapperState createState() => _FastDragWrapperState();
}

class _FastDragWrapperState extends State<FastDragWrapper>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;

  double _dragPosition = 0.0;
  bool _isDragging = false;
  bool _hasTriggered = false;

  @override
  void initState() {
    super.initState();

    // Single fast controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120), // Much faster
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.enabled) return;

    _isDragging = true;
    _hasTriggered = false;
    _controller.stop();

    if (widget.showFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.enabled || !_isDragging) return;

    setState(() {
      _dragPosition += details.delta.dx;

      // Immediate trigger when threshold is reached
      if (!_hasTriggered && _dragPosition.abs() > widget.sensitivity) {
        _hasTriggered = true;
        int direction = _dragPosition > 0 ? 1 : -1;

        // Trigger immediately
        widget.onDragComplete?.call(direction);

        if (widget.showFeedback) {
          HapticFeedback.selectionClick();
        }

        // Quick reset
        _resetPosition();
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.enabled || !_isDragging) return;

    _isDragging = false;

    // Check velocity for quick swipes
    if (!_hasTriggered) {
      double velocity = details.velocity.pixelsPerSecond.dx;

      if (velocity.abs() > widget.velocityThreshold) {
        int direction = velocity > 0 ? 1 : -1;
        widget.onDragComplete?.call(direction);

        if (widget.showFeedback) {
          HapticFeedback.selectionClick();
        }
      }
    }

    _resetPosition();
  }

  void _resetPosition() {
    _animation = Tween<double>(begin: _dragPosition, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward(from: 0).then((_) {
      setState(() {
        _dragPosition = 0.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        double currentPosition = _isDragging ? _dragPosition : _animation.value;

        return GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Transform.translate(
            offset: Offset(currentPosition * 0.05, 0), // Minimal visual movement
            child: widget.child,
          ),
        );
      },
    );
  }
}