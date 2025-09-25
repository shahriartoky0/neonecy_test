import 'package:flutter/material.dart';

class FadeAnimationWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final bool autoStart;
  final double startOpacity;
  final double endOpacity;

  const FadeAnimationWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.delay = Duration.zero,
    this.curve = Curves.easeInOut,
    this.autoStart = true,
    this.startOpacity = 0.0,
    this.endOpacity = 1.0,
  });

  @override
  State<FadeAnimationWidget> createState() => _FadeAnimationWidgetState();
}

class _FadeAnimationWidgetState extends State<FadeAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: widget.startOpacity,
      end: widget.endOpacity,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    if (widget.autoStart) {
      _startAnimation();
    }
  }

  void _startAnimation() async {
    if (widget.delay.inMilliseconds > 0) {
      await Future<void>.delayed(widget.delay);
    }
    if (mounted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Public methods to control animation
  void fadeIn() {
    _controller.forward();
  }

  void fadeOut() {
    _controller.reverse();
  }

  void reset() {
    _controller.reset();
  }

  void toggle() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

// Advanced version with more features
class AdvancedFadeAnimationWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final bool autoStart;
  final double startOpacity;
  final double endOpacity;
  final Offset? slideOffset; // Optional slide animation
  final double? scale; // Optional scale animation
  final VoidCallback? onComplete;

  const AdvancedFadeAnimationWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.delay = Duration.zero,
    this.curve = Curves.easeInOut,
    this.autoStart = true,
    this.startOpacity = 0.0,
    this.endOpacity = 1.0,
    this.slideOffset,
    this.scale,
    this.onComplete,
  });

  @override
  State<AdvancedFadeAnimationWidget> createState() => _AdvancedFadeAnimationWidgetState();
}

class _AdvancedFadeAnimationWidgetState extends State<AdvancedFadeAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset>? _slideAnimation;
  late Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: widget.startOpacity,
      end: widget.endOpacity,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    // Optional slide animation
    if (widget.slideOffset != null) {
      _slideAnimation = Tween<Offset>(
        begin: widget.slideOffset!,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: widget.curve,
        ),
      );
    }

    // Optional scale animation
    if (widget.scale != null) {
      _scaleAnimation = Tween<double>(
        begin: widget.scale!,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: widget.curve,
        ),
      );
    }

    // Add completion listener
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed && widget.onComplete != null) {
        widget.onComplete!();
      }
    });

    if (widget.autoStart) {
      _startAnimation();
    }
  }

  void _startAnimation() async {
    if (widget.delay.inMilliseconds > 0) {
      await Future.delayed(widget.delay);
    }
    if (mounted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Public methods to control animation
  void fadeIn() {
    _controller.forward();
  }

  void fadeOut() {
    _controller.reverse();
  }

  void reset() {
    _controller.reset();
  }

  void toggle() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        Widget animatedChild = Opacity(
          opacity: _fadeAnimation.value,
          child: widget.child,
        );

        // Apply scale animation if provided
        if (_scaleAnimation != null) {
          animatedChild = Transform.scale(
            scale: _scaleAnimation!.value,
            child: animatedChild,
          );
        }

        // Apply slide animation if provided
        if (_slideAnimation != null) {
          animatedChild = SlideTransition(
            position: _slideAnimation!,
            child: animatedChild,
          );
        }

        return animatedChild;
      },
    );
  }
}

// Staggered fade animation for lists
class StaggeredFadeAnimationWidget extends StatelessWidget {
  final List<Widget> children;
  final Duration duration;
  final Duration staggerDelay;
  final Curve curve;
  final Axis direction;

  const StaggeredFadeAnimationWidget({
    super.key,
    required this.children,
    this.duration = const Duration(milliseconds: 600),
    this.staggerDelay = const Duration(milliseconds: 100),
    this.curve = Curves.easeInOut,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return direction == Axis.vertical
        ? Column(
      children: _buildStaggeredChildren(),
    )
        : Row(
      children: _buildStaggeredChildren(),
    );
  }

  List<Widget> _buildStaggeredChildren() {
    return children.asMap().entries.map((MapEntry<int, Widget> entry) {
      int index = entry.key;
      Widget child = entry.value;

      return FadeAnimationWidget(
        duration: duration,
        delay: staggerDelay * index,
        curve: curve,
        child: child,
      );
    }).toList();
  }
}