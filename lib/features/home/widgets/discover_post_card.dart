// Changed lines are annotated. All existing colors, fonts, spacing, paddings,
// and widget structure are preserved exactly. Only the data-driven parts swap.

import 'package:cached_network_image/cached_network_image.dart'; // Changed: added for network avatar; already in pubspec
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
  // Changed: was `required String imagePath`; now a list supporting 0, 1, or 2 images
  final List<String> postImages;
  // Changed: new – local asset avatar path, always present as fallback
  final String avatarLocalPath;
  // Changed: new – URL from randomuser.me; nullable, null = skip network attempt
  final String? avatarNetworkUrl;
  final String priceChange;
  final bool isPositive;
  final int comments;
  final int likes;
  final int reposts;
  final int shares;
  // Changed: new – controls like-icon colour (yellow when true)
  final bool isLiked;
  // Changed: new – shows a yellow ✓ badge on the avatar when true
  final bool isVerified;

  const StockCard({
    super.key,
    required this.username,
    required this.timeAgo,
    required this.symbol,
    required this.question,
    required this.postImages,      // Changed: replaces imagePath
    required this.avatarLocalPath, // Changed: new
    this.avatarNetworkUrl,         // Changed: new, optional
    required this.priceChange,
    required this.isPositive,
    required this.comments,
    required this.likes,
    required this.reposts,
    required this.shares,
    required this.isLiked,    // Changed: new
    required this.isVerified, // Changed: new
  });

  // Unchanged: fallback colour derived from username initial
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

  // Unchanged
  String _formatViews(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toString();
  }

  // Changed: new helper – letter-only circle (ultimate fallback, same style as before)
  Widget _letterAvatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: _avatarColor, shape: BoxShape.circle),
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
    );
  }

  // Changed: new helper – local asset avatar, falls back to letter on load error
  Widget _localAvatar() {
    return ClipOval(
      child: Image.asset(
        avatarLocalPath,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _letterAvatar(),
      ),
    );
  }

  // Changed: new helper – full avatar with three-level fallback chain:
  //   1. network image (randomuser.me)  →  2. local asset  →  3. letter circle
  //   Plus optional verified-badge overlay in the bottom-right corner.
  Widget _buildAvatar() {
    final Widget photo = avatarNetworkUrl != null
        ? ClipOval(
            child: CachedNetworkImage(
              imageUrl: avatarNetworkUrl!,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              // Show local avatar while the network image loads
              placeholder: (_, __) => _localAvatar(),
              errorWidget: (_, __, ___) => _localAvatar(),
            ),
          )
        : _localAvatar();

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        SizedBox(width: 44, height: 44, child: photo),
        // Changed: verified badge overlaid on avatar bottom-right
        if (isVerified)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.yellow,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 10, color: Colors.black),
            ),
          ),
      ],
    );
  }

  // Changed: new helper – single post image (same visual as the old imagePath block)
  Widget _singleImage(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.sm),
      child: Container(
        width: double.infinity,
        height: 180,
        color: AppColors.grey.withValues(alpha: 0.1),
        child: Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.iconBackground,
            child: const Center(
              child: Icon(Icons.show_chart, color: Colors.white38, size: 40),
            ),
          ),
        ),
      ),
    );
  }

  // Changed: new helper – two images side by side with a 2 px gap
  Widget _doubleImage(String path1, String path2) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.sm),
      child: SizedBox(
        height: 180,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Image.asset(
                path1,
                fit: BoxFit.cover,
                height: 180,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.iconBackground,
                  child: const Center(
                    child: Icon(Icons.show_chart, color: Colors.white38, size: 30),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Image.asset(
                path2,
                fit: BoxFit.cover,
                height: 180,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.iconBackground,
                  child: const Center(
                    child: Icon(Icons.show_chart, color: Colors.white38, size: 30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Unchanged: view-count formula
    final int viewCount = comments * 7500 + likes * 200 + shares * 50 + 1000;

    return Padding(
      // Unchanged: same horizontal/vertical padding
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Header ──────────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Changed: was a plain letter-circle Container; now _buildAvatar()
              //          which tries network → local asset → letter circle
              _buildAvatar(),
              const SizedBox(width: 10), // unchanged
              // Unchanged: name + date column
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
                      style: const TextStyle(color: AppColors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Unchanged: dismiss icon
              GestureDetector(
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, color: AppColors.grey, size: 18),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10), // unchanged

          // ── Post text ────────────────────────────────────────────────────
          // Unchanged: RichText with yellow ticker prefix
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
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),

          // Changed: was an unconditional 180 px image block; now conditional on
          //          postImages.length — hidden for text-only posts, row for two images.
          if (postImages.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            if (postImages.length == 1)
              _singleImage(postImages[0])
            else
              _doubleImage(postImages[0], postImages[1]),
          ],

          const SizedBox(height: 10), // unchanged

          // ── Ticker tag ───────────────────────────────────────────────────
          // Unchanged: pill widget
          Row(
            children: <Widget>[
              _TickerTag(
                symbol: symbol,
                change: priceChange,
                isPositive: isPositive,
              ),
            ],
          ),

          const SizedBox(height: 10), // unchanged

          // ── Action bar ───────────────────────────────────────────────────
          // Changed: like icon now receives `color: isLiked ? yellow : null`
          //          so it turns yellow when the post is liked.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Unchanged: comment, repeat, views, share icons
              _SvgActionItem(assetPath: AppIcons.discoverComment, count: comments),
              _SvgActionItem(assetPath: AppIcons.discoverRepeat, count: reposts),
              // Changed: added color param driven by isLiked
              _SvgActionItem(
                assetPath: AppIcons.discoverLike,
                count: likes,
                color: isLiked ? AppColors.yellow : null,
              ),
              _IconActionItem(
                icon: Icons.bar_chart_rounded,
                count: _formatViews(viewCount),
              ),
              _SvgActionItem(assetPath: AppIcons.discoverShare, count: -1),
            ],
          ),

          const SizedBox(height: AppSizes.sm), // unchanged
        ],
      ),
    );
  }
}

// ── Sub-widgets (unchanged structure; _SvgActionItem gets one new param) ─────

class _TickerTag extends StatelessWidget {
  // Unchanged
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
    // Unchanged
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

class _SvgActionItem extends StatelessWidget {
  final String assetPath;
  final int count;
  // Changed: new optional param; when non-null tints the icon and count text
  final Color? color;

  const _SvgActionItem({
    required this.assetPath,
    required this.count,
    this.color, // Changed: new
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // Changed: passes color to CustomSvgImage (null = SVG's own colour)
        CustomSvgImage(assetName: assetPath, height: 18, color: color),
        if (count >= 0) ...<Widget>[
          const SizedBox(width: 5),
          Text(
            count.toString(),
            // Changed: count text mirrors icon colour when liked
            style: TextStyle(color: color ?? AppColors.grey, fontSize: 13),
          ),
        ],
      ],
    );
  }
}

class _IconActionItem extends StatelessWidget {
  // Unchanged
  final IconData icon;
  final String count;

  const _IconActionItem({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    // Unchanged
    return Row(
      children: <Widget>[
        Icon(icon, color: AppColors.grey, size: 18),
        const SizedBox(width: 5),
        Text(count, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
      ],
    );
  }
}
