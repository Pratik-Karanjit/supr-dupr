import 'dart:math';
import '../features/match_logging/models/match_record.dart';

class RatingCalculationResult {
  final double team1Delta;
  final double team2Delta;
  final double expectedWinProbTeam1;
  final double pointDifferentialFactor;

  const RatingCalculationResult({
    required this.team1Delta,
    required this.team2Delta,
    required this.expectedWinProbTeam1,
    required this.pointDifferentialFactor,
  });
}

class RatingAlgorithmService {
  /// Base K-factor scaled for 1.000 - 6.000 DUPR-like rating scale
  static const double baseKFactor = 0.160;

  /// Calculate expected probability that Team 1 beats Team 2
  /// On this scale, a 0.50 rating difference translates to roughly 76% win probability
  static double calculateExpectedScore(double ratingTeam1, double ratingTeam2) {
    final diff = ratingTeam1 - ratingTeam2;
    // Logistic curve normalized for pickleball rating scale
    return 1.0 / (1.0 + pow(10, -diff / 0.75));
  }

  /// Calculates dynamic K factor depending on player reliability index (0 - 100%)
  static double getDynamicK(int reliabilityIndex) {
    if (reliabilityIndex < 40) {
      return baseKFactor * 1.5; // High volatility for new unranked players
    } else if (reliabilityIndex < 75) {
      return baseKFactor * 1.15;
    } else {
      return baseKFactor * 0.90; // Established baseline
    }
  }

  /// Computes the rating adjustment for a confirmed match
  static RatingCalculationResult calculateMatchDeltas({
    required double team1AvgRating,
    required double team2AvgRating,
    required List<GameScore> games,
    int team1AvgReliability = 50,
    int team2AvgReliability = 50,
  }) {
    if (games.isEmpty) {
      return const RatingCalculationResult(
        team1Delta: 0.0,
        team2Delta: 0.0,
        expectedWinProbTeam1: 0.5,
        pointDifferentialFactor: 1.0,
      );
    }

    // 1. Calculate Expected Win Probability
    final e1 = calculateExpectedScore(team1AvgRating, team2AvgRating);

    // 2. Calculate Actual Outcome (1.0 if Team 1 won majority of games, 0.0 otherwise)
    int team1GamesWon = 0;
    int team2GamesWon = 0;
    int totalTeam1Points = 0;
    int totalTeam2Points = 0;

    for (final game in games) {
      if (game.isTeam1Winner) {
        team1GamesWon++;
      } else {
        team2GamesWon++;
      }
      totalTeam1Points += game.team1Score;
      totalTeam2Points += game.team2Score;
    }

    final double actualOutcome = team1GamesWon > team2GamesWon ? 1.0 : 0.0;

    // 3. Point Differential Factor
    // A blowout (e.g. 11-1, 11-2) increases delta; a close game (11-9, 12-10) attenuates delta
    final int totalPoints = totalTeam1Points + totalTeam2Points;
    double pointDifferentialFactor = 1.0;

    if (totalPoints > 0) {
      final pointDiffRatio = (totalTeam1Points - totalTeam2Points).abs() / totalPoints.toDouble();
      // Scale factor from 0.70 (very close match) up to 1.35 (dominant blowout)
      pointDifferentialFactor = 0.75 + (pointDiffRatio * 0.60);
    }

    // 4. Calculate K based on average reliability
    final avgReliability = ((team1AvgReliability + team2AvgReliability) / 2).round();
    final k = getDynamicK(avgReliability);

    // 5. Raw Delta
    final outcomeDifference = actualOutcome - e1;
    double rawDelta = k * outcomeDifference * pointDifferentialFactor;

    // Minimum movement guarantee for a confirmed victory (+0.02)
    if (actualOutcome == 1.0 && rawDelta < 0.02) {
      rawDelta = 0.02;
    } else if (actualOutcome == 0.0 && rawDelta > -0.02) {
      rawDelta = -0.02;
    }

    // Round to 3 decimal places
    final team1Delta = (rawDelta * 1000).round() / 1000;
    final team2Delta = ((-rawDelta) * 1000).round() / 1000;

    return RatingCalculationResult(
      team1Delta: team1Delta,
      team2Delta: team2Delta,
      expectedWinProbTeam1: (e1 * 100).round() / 100,
      pointDifferentialFactor: (pointDifferentialFactor * 100).round() / 100,
    );
  }

  /// Calculates new reliability index after confirmed matches
  static int updateReliabilityIndex(int currentReliability, int confirmedMatchesCount) {
    if (confirmedMatchesCount <= 1) return 25;
    if (confirmedMatchesCount <= 3) return 40;
    if (confirmedMatchesCount <= 6) return 60;
    if (confirmedMatchesCount <= 10) return 80;
    if (confirmedMatchesCount <= 15) return 92;
    return min(100, 92 + (confirmedMatchesCount - 15));
  }
}
