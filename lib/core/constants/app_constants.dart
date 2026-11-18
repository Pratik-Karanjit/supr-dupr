class AppConstants {
  static const String appName = 'Nepal Pickleball Rating';
  static const String appVersion = '1.0.0';
  
  // Rating baselines
  static const double defaultBaselineRating = 2.50;
  static const double minRating = 1.00;
  static const double maxRating = 6.00;
  
  // Default reliability index
  static const int minReliabilityForOfficialRank = 60; // 60% reliability required for ranked badge
  
  // Nepal Cities & Districts
  static const List<String> nepalCities = [
    'Kathmandu',
    'Lalitpur',
    'Bhaktapur',
    'Pokhara',
    'Chitwan',
    'Dharan',
    'Butwal',
  ];

  // Prominent Hubs & Clubs
  static const List<String> popularHubs = [
    'Tiptoe Pickleball Club (Sanepa)',
    'Boudha Pickleball Arena',
    'Dunkmandu Indoor Court',
    'Jhamsikhel Sports Hub',
    'Lakeside Pickleball Center (Pokhara)',
    'Baluwatar Smash Club',
  ];
}
