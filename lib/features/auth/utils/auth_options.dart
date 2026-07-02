class AuthOptions {
  AuthOptions._();

  static const List<String> countries = <String>[
    'Afghanistan', 'Argentina', 'Australia', 'Austria', 'Bangladesh', 'Belgium',
    'Brazil', 'Canada', 'China', 'Denmark', 'Egypt', 'Finland', 'France',
    'Germany', 'Greece', 'Hong Kong', 'India', 'Indonesia', 'Ireland', 'Italy',
    'Japan', 'Kenya', 'Kuwait', 'Malaysia', 'Mexico', 'Nepal', 'Netherlands',
    'New Zealand', 'Nigeria', 'Norway', 'Pakistan', 'Philippines', 'Poland',
    'Portugal', 'Qatar', 'Russia', 'Saudi Arabia', 'Singapore', 'South Africa',
    'South Korea', 'Spain', 'Sri Lanka', 'Sweden', 'Switzerland', 'Thailand',
    'Turkey', 'Ukraine', 'United Arab Emirates', 'United Kingdom',
    'United States', 'Vietnam',
  ];

  static const List<String> genders = <String>['Male', 'Female', 'Other'];

  /// label -> API language code
  static const Map<String, String> languages = <String, String>{
    'English': 'en',
    'Bengali': 'bn',
    'Hindi': 'hi',
    'Arabic': 'ar',
    'Chinese': 'zh',
    'French': 'fr',
    'German': 'de',
    'Japanese': 'ja',
    'Korean': 'ko',
    'Portuguese': 'pt',
    'Russian': 'ru',
    'Spanish': 'es',
    'Turkish': 'tr',
    'Urdu': 'ur',
  };
}