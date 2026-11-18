enum MatchType { singles, doubles }

enum MatchVerificationStatus {
  pendingVerification,
  confirmed,
  disputed
}

class GameScore {
  final int team1Score;
  final int team2Score;

  const GameScore({
    required this.team1Score,
    required this.team2Score,
  });

  bool get isTeam1Winner => team1Score > team2Score;
  int get differential => (team1Score - team2Score).abs();

  Map<String, dynamic> toJson() => {
    'team1Score': team1Score,
    'team2Score': team2Score,
  };

  factory GameScore.fromJson(Map<String, dynamic> json) => GameScore(
    team1Score: json['team1Score'] as int,
    team2Score: json['team2Score'] as int,
  );

  @override
  String toString() => '$team1Score - $team2Score';
}

class MatchRecord {
  final String id;
  final String matchCode; // e.g. "NPR-541"
  final MatchType type;
  final List<String> team1PlayerIds;
  final List<String> team1PlayerNames;
  final List<String> team2PlayerIds;
  final List<String> team2PlayerNames;
  final List<GameScore> gameScores;
  final DateTime date;
  final String loggedByPlayerId;
  final String loggedByPlayerName;
  final MatchVerificationStatus status;
  final double ratingDeltaTeam1;
  final double ratingDeltaTeam2;
  final String venueName;
  final String? disputeReason;

  const MatchRecord({
    required this.id,
    required this.matchCode,
    required this.type,
    required this.team1PlayerIds,
    required this.team1PlayerNames,
    required this.team2PlayerIds,
    required this.team2PlayerNames,
    required this.gameScores,
    required this.date,
    required this.loggedByPlayerId,
    required this.loggedByPlayerName,
    required this.status,
    this.ratingDeltaTeam1 = 0.0,
    this.ratingDeltaTeam2 = 0.0,
    required this.venueName,
    this.disputeReason,
  });

  int get team1GamesWon => gameScores.where((g) => g.isTeam1Winner).length;
  int get team2GamesWon => gameScores.where((g) => !g.isTeam1Winner).length;
  bool get isTeam1OverallWinner => team1GamesWon > team2GamesWon;

  MatchRecord copyWith({
    String? id,
    String? matchCode,
    MatchType? type,
    List<String>? team1PlayerIds,
    List<String>? team1PlayerNames,
    List<String>? team2PlayerIds,
    List<String>? team2PlayerNames,
    List<GameScore>? gameScores,
    DateTime? date,
    String? loggedByPlayerId,
    String? loggedByPlayerName,
    MatchVerificationStatus? status,
    double? ratingDeltaTeam1,
    double? ratingDeltaTeam2,
    String? venueName,
    String? disputeReason,
  }) {
    return MatchRecord(
      id: id ?? this.id,
      matchCode: matchCode ?? this.matchCode,
      type: type ?? this.type,
      team1PlayerIds: team1PlayerIds ?? this.team1PlayerIds,
      team1PlayerNames: team1PlayerNames ?? this.team1PlayerNames,
      team2PlayerIds: team2PlayerIds ?? this.team2PlayerIds,
      team2PlayerNames: team2PlayerNames ?? this.team2PlayerNames,
      gameScores: gameScores ?? this.gameScores,
      date: date ?? this.date,
      loggedByPlayerId: loggedByPlayerId ?? this.loggedByPlayerId,
      loggedByPlayerName: loggedByPlayerName ?? this.loggedByPlayerName,
      status: status ?? this.status,
      ratingDeltaTeam1: ratingDeltaTeam1 ?? this.ratingDeltaTeam1,
      ratingDeltaTeam2: ratingDeltaTeam2 ?? this.ratingDeltaTeam2,
      venueName: venueName ?? this.venueName,
      disputeReason: disputeReason ?? this.disputeReason,
    );
  }
}
