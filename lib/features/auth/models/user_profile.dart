class RatingHistoryPoint {
  final DateTime date;
  final double rating;
  final double delta;
  final String note;

  const RatingHistoryPoint({
    required this.date,
    required this.rating,
    required this.delta,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'rating': rating,
    'delta': delta,
    'note': note,
  };

  factory RatingHistoryPoint.fromJson(Map<String, dynamic> json) => RatingHistoryPoint(
    date: DateTime.parse(json['date'] as String),
    rating: (json['rating'] as num).toDouble(),
    delta: (json['delta'] as num).toDouble(),
    note: json['note'] as String? ?? '',
  );
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String city;
  final String homeHub;
  final double singlesRating;
  final double doublesRating;
  final int reliabilityScore; // 0 - 100%
  final int matchesPlayed;
  final int wins;
  final int losses;
  final List<RatingHistoryPoint> ratingHistory;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.city,
    required this.homeHub,
    required this.singlesRating,
    required this.doublesRating,
    required this.reliabilityScore,
    required this.matchesPlayed,
    required this.wins,
    required this.losses,
    required this.ratingHistory,
    this.avatarUrl,
  });

  double get winRate => matchesPlayed == 0 ? 0.0 : (wins / matchesPlayed) * 100;

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? city,
    String? homeHub,
    double? singlesRating,
    double? doublesRating,
    int? reliabilityScore,
    int? matchesPlayed,
    int? wins,
    int? losses,
    List<RatingHistoryPoint>? ratingHistory,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      city: city ?? this.city,
      homeHub: homeHub ?? this.homeHub,
      singlesRating: singlesRating ?? this.singlesRating,
      doublesRating: doublesRating ?? this.doublesRating,
      reliabilityScore: reliabilityScore ?? this.reliabilityScore,
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      ratingHistory: ratingHistory ?? this.ratingHistory,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
