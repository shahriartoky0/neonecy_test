// Changed: replaced static kMockPosts list with a dynamic generatePosts()
// function. MockPost expanded with postImages, avatar fields, isLiked,
// isVerified. All pools are constants; only the selection is randomised.

import 'dart:convert'; // for jsonDecode of randomuser.me response
import 'dart:math';

import 'package:http/http.dart' as http; // already in pubspec; not a new package

// ── Model ────────────────────────────────────────────────────────────────────

class MockPost {
  final String username;
  final String timeAgo;
  final String symbol;
  final String question;
  final List<String> postImages; // Changed: was String imagePath; now 0–2 asset paths
  final String avatarLocalPath;  // Changed: new – local user image, always available
  final String? avatarNetworkUrl; // Changed: new – from randomuser.me, null on error
  final String priceChange;
  final bool isPositive;
  final int comments;
  final int likes;
  final int reposts;
  final int shares;
  final bool isLiked;   // Changed: new – 30 % chance of being true
  final bool isVerified; // Changed: new – 20 % chance of showing badge

  const MockPost({
    required this.username,
    required this.timeAgo,
    required this.symbol,
    required this.question,
    required this.postImages,
    required this.avatarLocalPath,
    this.avatarNetworkUrl,
    required this.priceChange,
    required this.isPositive,
    required this.comments,
    required this.likes,
    required this.reposts,
    required this.shares,
    required this.isLiked,
    required this.isVerified,
  });
}

// ── Static data pools ─────────────────────────────────────────────────────────
// Changed: replaced 8-item hardcoded list with proper pools for every field.

const List<String> _kPostImages = <String>[
  'assets/posts_images/1.png',
  'assets/posts_images/2.png',
  'assets/posts_images/3.png',
  'assets/posts_images/4.png',
  'assets/posts_images/5.png',
  'assets/posts_images/6.png',
  'assets/posts_images/7.png',
  'assets/posts_images/8.png',
  'assets/posts_images/9.png',
];

const List<String> _kUserImages = <String>[
  'assets/posts_images/user_images/1.png',
  'assets/posts_images/user_images/2.png',
  'assets/posts_images/user_images/3.png',
  'assets/posts_images/user_images/4.png',
  'assets/posts_images/user_images/5.png',
  'assets/posts_images/user_images/6.png',
  'assets/posts_images/user_images/7.png',
];

const List<String> _kUsernames = <String>[
  'CryptoWhale', 'SatoshiFan', 'BTCMaestro', 'EthHodler', 'MoonTrader99',
  'DeFiGuru', 'ChainAnalyst', 'BlockBull', 'AltcoinKing', 'ShariaTrader',
  'WalletWatcher', 'HashRatePro', 'CryptoSara', 'NakamotoJr', 'PumpHunter',
  'StableSam', 'LiquidityLuke', 'GasFeeMike', 'ZkProofZara', 'YieldFarmer',
];

const List<String> _kTimeAgo = <String>[
  '2m ago', '5m ago', '14m ago', '23m ago', '28m ago', '47m ago',
  '1h ago', '2h ago', '3h ago', '4h ago', '5h ago', '8h ago',
  '12h ago', '1d ago',
];

const List<String> _kSymbols = <String>[
  'BTC', 'ETH', 'BNB', 'SOL', 'ADA', 'XRP',
  'DOGE', 'AVAX', 'MATIC', 'DOT', 'LINK', 'ATOM',
  'NEAR', 'ARB', 'OP',
];

const List<String> _kPosts = <String>[
  'Just broke through resistance. Are we finally going parabolic? 🚀',
  'Major whale just moved 2,400 coins to Binance. Sell incoming? 🐳',
  "If you bought the dip last week you're up 18% already. Patience pays.",
  'Network congestion is back. Gas fees through the roof again 😤',
  'The halving effect is real. Historical patterns never lie.',
  'RSI hit 72 on the 4H chart. Cooling off or continuation?',
  "Remember when everyone said crypto was dead? Here we are again 😄",
  'New partnership announcement dropping soon. Watch this space 👀',
  'Volume is 3× the 30-day average. Something big is brewing.',
  'Is the bear market truly over or just a dead-cat bounce?',
  'Staking rewards dropped to 4.2 % APY. Still worth it long-term?',
  'Institutional buying accelerated this week. Follow the smart money 💰',
  'Liquidated \$240M in longs today. Market needed that flush.',
  'My DCA strategy is up 67 % from the bottom. Slow and steady wins 🏆',
  'Chain activity at ATH while price is sideways — bullish divergence.',
  'Never trust a token with 0 GitHub commits in 6 months 🚩',
  'Layer-2 TVL hit new highs. Scaling is finally working.',
  'Short squeeze incoming? Funding rates are extremely negative right now.',
  'Portfolio green for the first time in 3 months. Feels good 💚',
  'On-chain data shows accumulation by wallets holding 100–1 000 coins.',
  "Break above \$68k and we're in price discovery territory 🎯",
  'Macro improving. Rate cuts = risk-on assets pump. Position accordingly.',
  'Moved 50 % to stables. Sleep better than chasing pumps ngl.',
  'New ATH or false breakout? Drop your TA below 👇',
];

// ── Image queue builder ───────────────────────────────────────────────────────

// Changed: shuffles and extends the post-image pool to 30+ entries, then
// removes consecutive duplicates so the feed never shows the same image twice
// in a row.
List<String> _buildImageQueue(Random rng) {
  final List<String> queue = <String>[];
  final List<String> pool = List<String>.from(_kPostImages);
  while (queue.length < 30) {
    pool.shuffle(rng);
    queue.addAll(pool);
  }
  // Swap any adjacent duplicates with a later different element.
  for (int i = queue.length - 1; i > 0; i--) {
    if (queue[i] == queue[i - 1]) {
      for (int j = i + 1; j < queue.length; j++) {
        if (queue[j] != queue[i - 1]) {
          final String temp = queue[i];
          queue[i] = queue[j];
          queue[j] = temp;
          break;
        }
      }
    }
  }
  return queue;
}

// ── Public generation function ────────────────────────────────────────────────

// Changed: replaces kMockPosts. Called from the controller's randomizePosts()
// on every mount and pull-to-refresh. Uses a fresh Random() each call so the
// feed is never the same twice. Fetches 12 avatars from randomuser.me in a
// single request and falls back silently to local assets on any error.
Future<List<MockPost>> generatePosts() async {
  final Random rng = Random(); // no fixed seed → different every call

  // Attempt to fetch 12 real avatar URLs in one network call.
  final List<String?> networkAvatars = List<String?>.filled(12, null);
  try {
    final http.Response response = await http
        .get(Uri.parse('https://randomuser.me/api/?results=12&inc=picture'))
        .timeout(const Duration(seconds: 4));
    if (response.statusCode == 200) {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> results = body['results'] as List<dynamic>;
      for (int i = 0; i < results.length && i < 12; i++) {
        networkAvatars[i] =
            results[i]['picture']?['medium'] as String?;
      }
    }
  } catch (_) {
    // Network unavailable or timeout — networkAvatars stays all-null,
    // StockCard will fall back to local asset avatars.
  }

  final List<String> imageQueue = _buildImageQueue(rng);
  int imgIdx = 0;

  // Returns the next image from the de-duplicated queue.
  String nextImg() {
    final String img = imageQueue[imgIdx % imageQueue.length];
    imgIdx++;
    return img;
  }

  return List<MockPost>.generate(12, (int i) {
    // Image layout distribution: 25 % none / 55 % one / 20 % two.
    final double roll = rng.nextDouble();
    final List<String> postImages;
    if (roll < 0.25) {
      postImages = <String>[];
    } else if (roll < 0.80) {
      postImages = <String>[nextImg()];
    } else {
      postImages = <String>[nextImg(), nextImg()];
    }

    final bool isPositive = rng.nextBool();
    final double pct = 0.01 + rng.nextDouble() * 19.99;

    return MockPost(
      username: _kUsernames[rng.nextInt(_kUsernames.length)],
      timeAgo: _kTimeAgo[rng.nextInt(_kTimeAgo.length)],
      symbol: _kSymbols[rng.nextInt(_kSymbols.length)],
      question: _kPosts[rng.nextInt(_kPosts.length)],
      postImages: postImages,
      avatarLocalPath: _kUserImages[rng.nextInt(_kUserImages.length)],
      avatarNetworkUrl: networkAvatars[i], // null when network failed
      priceChange: '${isPositive ? '+' : '-'}${pct.toStringAsFixed(2)}%',
      isPositive: isPositive,
      comments: rng.nextInt(181),            // 0–180
      likes: 8 + rng.nextInt(3393),          // 8–3400
      reposts: rng.nextInt(300),             // 0–299
      shares: rng.nextInt(50),               // 0–49
      isLiked: rng.nextDouble() < 0.30,      // 30 % true
      isVerified: rng.nextDouble() < 0.20,   // 20 % true
    );
  });
}
