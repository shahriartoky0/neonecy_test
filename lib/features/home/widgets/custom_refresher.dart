import 'package:flutter/material.dart';
import 'package:neonecy_test/core/design/app_colors.dart';

class CustomGifRefreshWidget extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String gifAssetPath;
  final double refreshTriggerDistance;
  final VoidCallback? onRefreshStart;
  final VoidCallback? onRefreshComplete;

  const CustomGifRefreshWidget({
    super.key,
    required this.child,
    required this.onRefresh,
    required this.gifAssetPath,
    this.refreshTriggerDistance = 100.0,
    this.onRefreshStart,
    this.onRefreshComplete,
  });

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
      duration: const Duration(milliseconds: 200),
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

    setState(() => _isRefreshing = true);
    widget.onRefreshStart?.call();
    _animationController.forward();

    // ✅ KEY FIX: Fire the API call in the background — don't await it.
    // The loader hides after a fixed ~800ms instead of blocking on the full API response.
    widget.onRefresh().catchError((error) {
      debugPrint("Refresh failed: $error");
    });

    // ✅ Loader visible for max 800ms regardless of API speed (tune as needed)
    await Future.delayed(const Duration(milliseconds: 800));

    await _animationController.reverse();

    if (mounted) {
      setState(() {
        _isRefreshing = false;
        _dragDistance = 0.0;
        _canRefresh = false;
      });
    }

    widget.onRefreshComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification.metrics.pixels <= 0) {
          _isAtTop = true;
        } else {
          _isAtTop = false;
        }

        if (notification is OverscrollNotification && _isAtTop) {
          if (notification.overscroll < 0 && !_isRefreshing) {
            setState(() {
              _dragDistance += (-notification.overscroll * 5);
              _dragDistance = _dragDistance.clamp(0.0, widget.refreshTriggerDistance * 2);
              _canRefresh = _dragDistance >= widget.refreshTriggerDistance;
            });
          }
        }

        if (notification is ScrollEndNotification) {
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
          AnimatedContainer(
            decoration: const BoxDecoration(),
            duration: const Duration(milliseconds: 200),
            height: _dragDistance > 0 || _isRefreshing
                ? _isRefreshing
                ? 80.0
                : (_dragDistance * 0.8).clamp(0.0, 80.0)
                : 0.0,
            width: double.infinity,
            child: _dragDistance > 0 || _isRefreshing
                ? AnimatedBuilder(
              animation: _animationController,
              builder: (BuildContext context, Widget? child) {
                return Center(
                  child: AnimatedScale(
                    scale: _isRefreshing
                        ? _scaleAnimation.value
                        : (0.3 + (_dragDistance / widget.refreshTriggerDistance) * 0.7)
                        .clamp(0.3, 1.0),
                    duration: const Duration(milliseconds: 100),
                    child: AnimatedOpacity(
                      opacity: _isRefreshing
                          ? 1.0
                          : (_dragDistance / widget.refreshTriggerDistance).clamp(0.3, 1.0),
                      duration: const Duration(milliseconds: 100),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: Image.asset(widget.gifAssetPath, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                );
              },
            )
                : const SizedBox.shrink(),
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}