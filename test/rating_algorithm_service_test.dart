import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_pickleball_rating/services/rating_algorithm_service.dart';
import 'package:nepal_pickleball_rating/features/match_logging/models/match_record.dart';

void main() {
  group('RatingAlgorithmService Unit Tests', () {
    test('calculateExpectedScore returns higher probability for higher rated player', () {
      final probHigher = RatingAlgorithmService.calculateExpectedScore(4.0, 3.0);
      final probLower = RatingAlgorithmService.calculateExpectedScore(3.0, 4.0);

      expect(probHigher > 0.70, true);
      expect(probLower < 0.30, true);
      expect((probHigher + probLower).toStringAsFixed(2), '1.00');
    });

    test('calculateMatchDeltas awards higher delta for blowout vs close match', () {
      // Dominant blowout: 11-1, 11-2
      final blowoutResult = RatingAlgorithmService.calculateMatchDeltas(
        team1AvgRating: 3.5,
        team2AvgRating: 3.5,
        games: const [
          GameScore(team1Score: 11, team2Score: 1),
          GameScore(team1Score: 11, team2Score: 2),
        ],
      );

      // Close deuce game: 11-9, 12-10
      final closeResult = RatingAlgorithmService.calculateMatchDeltas(
        team1AvgRating: 3.5,
        team2AvgRating: 3.5,
        games: const [
          GameScore(team1Score: 11, team2Score: 9),
          GameScore(team1Score: 12, team2Score: 10),
        ],
      );

      expect(blowoutResult.team1Delta > closeResult.team1Delta, true);
      expect(blowoutResult.pointDifferentialFactor > closeResult.pointDifferentialFactor, true);
    });

    test('updateReliabilityIndex progresses with confirmed matches', () {
      final initial = RatingAlgorithmService.updateReliabilityIndex(20, 1);
      final mid = RatingAlgorithmService.updateReliabilityIndex(20, 6);
      final high = RatingAlgorithmService.updateReliabilityIndex(20, 15);

      expect(initial, 25);
      expect(mid, 60);
      expect(high, 92);
    });
  });
}
