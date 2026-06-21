import 'package:flutter/material.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/design/app_icons.dart';

class StockCard extends StatelessWidget {
  final String username;
  final String timeAgo;
  final String symbol;
  final String question;
  final String imagePath;
  final String priceChange;
  final bool isPositive;
  final int comments;
  final int likes;
  final int reposts;
  final int shares;

  const StockCard({
    super.key,
    required this.username,
    required this.timeAgo,
    required this.symbol,
    required this.question,
    required this.imagePath,
    required this.priceChange,
    required this.isPositive,
    required this.comments,
    required this.likes,
    required this.reposts,
    required this.shares,
  });

  // Derive a consistent color from the first letter of the username
  Color get _avatarColor {
    final int code = username.isEmpty ? 0 : username.codeUnitAt(0);
    const List<Color> palette = <Color>[
      Color(0xFF1565C0),
      Color(0xFF6A1B9A),
      Color(0xFF00838F),
      Color(0xFF2E7D32),
      Color(0xFFAD1457),
      Color(0xFFE65100),
      Color(0xFF37474F),
    ];
    return palette[code % palette.length];
  }

  // Format view count with K/M suffix
  String _formatViews(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    final int viewCount = comments * 7500 + likes * 200 + shares * 50 + 1000;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Header: avatar + name/date + dismiss ────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Circular letter avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _avatarColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Name and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '• $timeAgo',
                      style: const TextStyle(
                          color: AppColors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Dismiss icon
              GestureDetector(
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close,
                      color: AppColors.grey, size: 18),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Content ─────────────────────────────────────────────
          RichText(
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: '\$$symbol ',
                  style: const TextStyle(
                    color: AppColors.yellow,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: question,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Chart image ──────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.sm),
            child: Container(
              width: double.infinity,
              height: 180,
              color: AppColors.grey.withValues(alpha: 0.1),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.iconBackground,
                  child: const Center(
                    child: Icon(Icons.show_chart,
                        color: Colors.white38, size: 40),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Ticker tag pill ──────────────────────────────────────
          Row(
            children: <Widget>[
              _TickerTag(
                symbol: symbol,
                change: priceChange,
                isPositive: isPositive,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Action bar ───────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _SvgActionItem(
                  assetPath: AppIcons.discoverComment, count: comments),
              _SvgActionItem(
                  assetPath: AppIcons.discoverRepeat, count: reposts),
              _SvgActionItem(
                  assetPath: AppIcons.discoverLike, count: likes),
              _IconActionItem(
                icon: Icons.bar_chart_rounded,
                count: _formatViews(viewCount),
              ),
              _SvgActionItem(assetPath: AppIcons.discoverShare, count: -1),
            ],
          ),

          const SizedBox(height: AppSizes.sm),
        ],
      ),
    );
  }
}

// Pill-shaped ticker tag (e.g. "BTC +2.34%")
class _TickerTag extends StatelessWidget {
  final String symbol;
  final String change;
  final bool isPositive;

  const _TickerTag({
    required this.symbol,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.iconBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            symbol,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            change,
            style: TextStyle(
              color: isPositive ? AppColors.greenAccent : AppColors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Action item using existing SVG icons
class _SvgActionItem extends StatelessWidget {
  final String assetPath;
  final int count;

  const _SvgActionItem({required this.assetPath, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CustomSvgImage(assetName: assetPath, height: 18),
        if (count >= 0) ...<Widget>[
          const SizedBox(width: 5),
          Text(
            count.toString(),
            style: const TextStyle(color: AppColors.grey, fontSize: 13),
          ),
        ],
      ],
    );
  }
}

// Action item using Material icon (for views)
class _IconActionItem extends StatelessWidget {
  final IconData icon;
  final String count;

  const _IconActionItem({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, color: AppColors.grey, size: 18),
        const SizedBox(width: 5),
        Text(count,
            style: const TextStyle(color: AppColors.grey, fontSize: 13)),
      ],
    );
  }
}
