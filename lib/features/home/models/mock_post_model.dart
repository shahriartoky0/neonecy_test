class MockPost {
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

  const MockPost({
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
}

const List<MockPost> kMockPosts = <MockPost>[
  MockPost(
    username: 'FARUK',
    timeAgo: '3h',
    symbol: 'SOM',
    question: 'Again possible or not?',
    imagePath: 'assets/images/demo_image.png',
    priceChange: '-11.88%',
    isPositive: false,
    comments: 12,
    likes: 19,
    reposts: 18,
    shares: 0,
  ),
  MockPost(
    username: 'ALICE',
    timeAgo: '1h',
    symbol: 'BTC',
    question: 'Will it drop below 40k?',
    imagePath: 'assets/images/demo_image.png',
    priceChange: '+2.45%',
    isPositive: true,
    comments: 8,
    likes: 25,
    reposts: 12,
    shares: 3,
  ),
  MockPost(
    username: 'CRYPTO_KING',
    timeAgo: '5h',
    symbol: 'ETH',
    question: 'ETH 2.0 update — bullish or bearish?',
    imagePath: 'assets/images/demo_image.png',
    priceChange: '+5.20%',
    isPositive: true,
    comments: 34,
    likes: 87,
    reposts: 23,
    shares: 11,
  ),
  MockPost(
    username: 'MOON_TRADER',
    timeAgo: '2h',
    symbol: 'BNB',
    question: 'BNB breaking resistance soon?',
    imagePath: 'assets/images/demo_image.png',
    priceChange: '-1.03%',
    isPositive: false,
    comments: 5,
    likes: 14,
    reposts: 4,
    shares: 2,
  ),
  MockPost(
    username: 'HODLER99',
    timeAgo: '8h',
    symbol: 'SOL',
    question: 'Solana network congestion — should we be worried?',
    imagePath: 'assets/images/demo_image.png',
    priceChange: '+8.77%',
    isPositive: true,
    comments: 47,
    likes: 102,
    reposts: 31,
    shares: 15,
  ),
  MockPost(
    username: 'WHALE_WATCH',
    timeAgo: '30m',
    symbol: 'DOGE',
    question: 'Large DOGE movement detected on-chain!',
    imagePath: 'assets/images/demo_image.png',
    priceChange: '+0.55%',
    isPositive: true,
    comments: 21,
    likes: 56,
    reposts: 9,
    shares: 7,
  ),
  MockPost(
    username: 'DEFI_GURU',
    timeAgo: '12h',
    symbol: 'AVAX',
    question: 'New DeFi protocols on Avalanche — bullish signal?',
    imagePath: 'assets/images/demo_image.png',
    priceChange: '-3.14%',
    isPositive: false,
    comments: 18,
    likes: 44,
    reposts: 16,
    shares: 5,
  ),
  MockPost(
    username: 'SARA_CRYPTO',
    timeAgo: '6h',
    symbol: 'ADA',
    question: 'Cardano staking rewards — worth it in 2025?',
    imagePath: 'assets/images/demo_image.png',
    priceChange: '+1.22%',
    isPositive: true,
    comments: 9,
    likes: 33,
    reposts: 7,
    shares: 1,
  ),
];