import 'package:flutter/material.dart';
import 'package:neonecy_test/core/design/app_colors.dart';

class CustomGifRefreshWidget extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String gifAssetPath;
  final double refreshTriggerDistance;

  const CustomGifRefreshWidget({
    Key? key,
    required this.child,
    required this.onRefresh,
    required this.gifAssetPath,
    this.refreshTriggerDistance = 100.0,
  }) : super(key: key);

  @override
  State<CustomGifRefreshWidget> createState() => _CustomGifRefreshWidgetState();
}

class _CustomGifRefreshWidgetState extends State<CustomGifRefreshWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _isRefreshing = false;
  double _dragDistance = 0.0;
  bool _canRefresh = false;
  bool _isAtTop = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleRefresh() async {
    if (_isRefreshing) return;

    print("Starting refresh..."); // Debug print
    setState(() {
      _isRefreshing = true;
    });

    _animationController.forward();

    try {
      await widget.onRefresh();
      print("Refresh completed successfully"); // Debug print
    } catch (error) {
      print("Refresh failed: $error"); // Debug print
    } finally {
      await _animationController.reverse();
      setState(() {
        _isRefreshing = false;
        _dragDistance = 0.0;
        _canRefresh = false;
      });
      print("Refresh cycle finished"); // Debug print
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        // Check if we're at the top
        if (notification.metrics.pixels <= 0) {
          _isAtTop = true;
        } else {
          _isAtTop = false;
        }

        // Handle overscroll when at top
        if (notification is OverscrollNotification && _isAtTop) {
          if (notification.overscroll < 0 && !_isRefreshing) {
            print("Overscroll detected: ${notification.overscroll}"); // Debug print
            setState(() {
              // Accumulate drag distance instead of replacing it
              _dragDistance +=
              (-notification.overscroll * 5); // Multiply by 5 to make it more sensitive
              _dragDistance = _dragDistance.clamp(0.0, widget.refreshTriggerDistance * 2);
              _canRefresh = _dragDistance >= widget.refreshTriggerDistance;
            });
            print("Drag distance: $_dragDistance, Can refresh: $_canRefresh"); // Debug print
          }
        }

        // Handle scroll end
        if (notification is ScrollEndNotification) {
          print("Scroll ended. Can refresh: $_canRefresh"); // Debug print
          if (_canRefresh && !_isRefreshing) {
            _handleRefresh();
          } else if (!_isRefreshing) {
            setState(() {
              _dragDistance = 0.0;
              _canRefresh = false;
            });
          }
        }

        return false;
      },
      child: Column(
        children: <Widget>[
          // Refresh indicator at the top - takes its own space
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _dragDistance > 0 || _isRefreshing
                ? _isRefreshing
                ? 80.0
                : (_dragDistance * 0.8).clamp(0.0, 80.0)
                : 0.0,
            width: double.infinity,
            color: Colors.transparent, // You can change this to AppColors.primaryColor if needed
            child: _dragDistance > 0 || _isRefreshing
                ? AnimatedBuilder(
              animation: _animationController,
              builder: (BuildContext context, Widget? child) {
                return Center(
                  child: AnimatedScale(
                    scale: _isRefreshing
                        ? _scaleAnimation.value
                        : (0.3 + (_dragDistance / widget.refreshTriggerDistance) * 0.7).clamp(
                      0.3,
                      1.0,
                    ),
                    duration: const Duration(milliseconds: 100),
                    child: AnimatedOpacity(
                      opacity: _isRefreshing
                          ? 1.0
                          : (_dragDistance / widget.refreshTriggerDistance).clamp(0.3, 1.0),
                      duration: const Duration(milliseconds: 100),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Image.asset(widget.gifAssetPath, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                );
              },
            )
                : const SizedBox.shrink(),
          ),

          // Main content - takes remaining space
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}