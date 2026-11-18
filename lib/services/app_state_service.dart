import 'dart:math';
import 'package:flutter/foundation.dart';
import '../features/auth/models/user_profile.dart';
import '../features/match_logging/models/match_record.dart';
import '../features/venues/models/pickleball_venue.dart';
import 'rating_algorithm_service.dart';

class AppStateService extends ChangeNotifier {
  static final AppStateService _instance = AppStateService._internal();
  factory AppStateService() => _instance;

  AppStateService._internal() {
    _initializeSeedData();
  }

  bool _isLoggedIn = true;
  UserProfile? _currentUser;
  final List<UserProfile> _communityPlayers = [];
  final List<MatchRecord> _matches = [];
  final List<PickleballVenue> _venues = [];
  String? _currentCheckedInVenueId;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  UserProfile get currentUser => _currentUser ?? _defaultGuestProfile;
  List<UserProfile> get communityPlayers => List.unmodifiable(_communityPlayers);
  List<MatchRecord> get matches => List.unmodifiable(_matches);
  List<PickleballVenue> get venues => List.unmodifiable(_venues);
  String? get currentCheckedInVenueId => _currentCheckedInVenueId;

  List<MatchRecord> get pendingVerificationMatches => _matches
      .where((m) => m.status == MatchVerificationStatus.pendingVerification)
      .toList();

  List<MatchRecord> get confirmedMatches => _matches
      .where((m) => m.status == MatchVerificationStatus.confirmed)
      .toList();

  static final UserProfile _defaultGuestProfile = UserProfile(
    id: 'user_pratik',
    name: 'Pratik Sharma',
    email: 'pratik@pickleballnepal.org',
    city: 'Kathmandu',
    homeHub: 'Tiptoe Pickleball Club (Sanepa)',
    singlesRating: 3.420,
    doublesRating: 3.585,
    reliabilityScore: 84,
    matchesPlayed: 14,
    wins: 10,
    losses: 4,
    ratingHistory: [
      RatingHistoryPoint(
        date: DateTime.now().subtract(const Duration(days: 28)),
        rating: 3.100,
        delta: 0.0,
        note: 'Initial verified baseline',
      ),
      RatingHistoryPoint(
        date: DateTime.now().subtract(const Duration(days: 20)),
        rating: 3.240,
        delta: 0.140,
        note: 'Win vs Rohan (11-7, 11-8) at Tiptoe',
      ),
      RatingHistoryPoint(
        date: DateTime.now().subtract(const Duration(days: 14)),
        rating: 3.310,
        delta: 0.070,
        note: 'Win vs Team Pokhara (11-9, 12-10)',
      ),
      RatingHistoryPoint(
        date: DateTime.now().subtract(const Duration(days: 8)),
        rating: 3.250,
        delta: -0.060,
        note: 'Loss vs Bibek & Sandeep (8-11, 11-9, 7-11)',
      ),
      RatingHistoryPoint(
        date: DateTime.now().subtract(const Duration(days: 2)),
        rating: 3.585,
        delta: 0.335,
        note: 'Dominant 2-0 win at Boudha Arena (11-4, 11-5)',
      ),
    ],
  );

  void _initializeSeedData() {
    _currentUser = _defaultGuestProfile;

    // Seed community players across Nepal
    _communityPlayers.addAll([
      _defaultGuestProfile,
      UserProfile(
        id: 'p_rohan',
        name: 'Rohan Shrestha',
        email: 'rohan.s@gmail.com',
        city: 'Kathmandu',
        homeHub: 'Tiptoe Pickleball Club (Sanepa)',
        singlesRating: 4.120,
        doublesRating: 4.250,
        reliabilityScore: 92,
        matchesPlayed: 34,
        wins: 26,
        losses: 8,
        ratingHistory: [],
      ),
      UserProfile(
        id: 'p_anjali',
        name: 'Anjali Tamang',
        email: 'anjali.t@gmail.com',
        city: 'Kathmandu',
        homeHub: 'Boudha Pickleball Arena',
        singlesRating: 3.820,
        doublesRating: 3.910,
        reliabilityScore: 88,
        matchesPlayed: 24,
        wins: 17,
        losses: 7,
        ratingHistory: [],
      ),
      UserProfile(
        id: 'p_bibek',
        name: 'Bibek Thapa',
        email: 'bibek.thapa@gmail.com',
        city: 'Lalitpur',
        homeHub: 'Jhamsikhel Sports Hub',
        singlesRating: 3.650,
        doublesRating: 3.780,
        reliabilityScore: 80,
        matchesPlayed: 19,
        wins: 12,
        losses: 7,
        ratingHistory: [],
      ),
      UserProfile(
        id: 'p_sneha',
        name: 'Sneha Shakya',
        email: 'sneha.shakya@gmail.com',
        city: 'Kathmandu',
        homeHub: 'Dunkmandu Indoor Court',
        singlesRating: 3.250,
        doublesRating: 3.420,
        reliabilityScore: 75,
        matchesPlayed: 15,
        wins: 9,
        losses: 6,
        ratingHistory: [],
      ),
      UserProfile(
        id: 'p_aayush',
        name: 'Aayush Karki',
        email: 'aayush.k@gmail.com',
        city: 'Pokhara',
        homeHub: 'Lakeside Pickleball Center (Pokhara)',
        singlesRating: 4.350,
        doublesRating: 4.410,
        reliabilityScore: 95,
        matchesPlayed: 42,
        wins: 33,
        losses: 9,
        ratingHistory: [],
      ),
      UserProfile(
        id: 'p_sujan',
        name: 'Sujan Maharjan',
        email: 'sujan.m@gmail.com',
        city: 'Kathmandu',
        homeHub: 'Baluwatar Smash Club',
        singlesRating: 2.850,
        doublesRating: 2.920,
        reliabilityScore: 60,
        matchesPlayed: 8,
        wins: 4,
        losses: 4,
        ratingHistory: [],
      ),
    ]);

    // Seed Venues in Nepal
    _venues.addAll([
      const PickleballVenue(
        id: 'v_tiptoe',
        name: 'Tiptoe Pickleball Club',
        location: 'Sanepa, Lalitpur',
        fullAddress: 'Ward 2, Sanepa (near British School), Lalitpur',
        courtsCount: 4,
        surfaceType: 'Pro Cushion Acrylic Hardcourt',
        openHours: '06:00 AM - 09:30 PM',
        activePlayersCount: 8,
        contactPhone: '+977-9801234567',
        amenities: ['Floodlights', 'Equipment Rental', 'Cafe', 'Showers'],
      ),
      const PickleballVenue(
        id: 'v_boudha',
        name: 'Boudha Pickleball Arena',
        location: 'Boudha, Kathmandu',
        fullAddress: 'Tusal Road, Near Boudhanath Stupa, Kathmandu',
        courtsCount: 3,
        surfaceType: 'High-Grip Outdoor Polymer',
        openHours: '06:30 AM - 08:00 PM',
        activePlayersCount: 6,
        contactPhone: '+977-9812345678',
        amenities: ['Paddle Rental', 'Parking', 'Pro Shop', 'Lounge'],
      ),
      const PickleballVenue(
        id: 'v_dunkmandu',
        name: 'Dunkmandu Sports Hub',
        location: 'Chuchepati, Kathmandu',
        fullAddress: 'Chuchepati Sports Complex, Kathmandu',
        courtsCount: 2,
        surfaceType: 'Indoor Maple Woodcourt',
        openHours: '07:00 AM - 10:00 PM',
        activePlayersCount: 4,
        contactPhone: '+977-9841238910',
        amenities: ['Indoor Climate', 'Spectator Seating', 'Lockers'],
      ),
      const PickleballVenue(
        id: 'v_jhamsikhel',
        name: 'Jhamsikhel Pickleball Corner',
        location: 'Jhamsikhel, Lalitpur',
        fullAddress: 'Near Restaurant Row, Jhamsikhel, Lalitpur',
        courtsCount: 2,
        surfaceType: 'Dedicated All-Weather Hardcourt',
        openHours: '06:00 AM - 08:30 PM',
        activePlayersCount: 5,
        contactPhone: '+977-9851122334',
        amenities: ['Night Floodlights', 'Coaching Available', 'Water Station'],
      ),
      const PickleballVenue(
        id: 'v_pokhara',
        name: 'Lakeside Pickleball Center',
        location: 'Lakeside, Pokhara',
        fullAddress: 'Barahi Path, Lakeside, Pokhara-6',
        courtsCount: 4,
        surfaceType: 'Outdoor Scenic Hardcourt',
        openHours: '06:00 AM - 09:00 PM',
        activePlayersCount: 11,
        contactPhone: '+977-9861002233',
        amenities: ['Mountain View', 'Paddle Rental', 'Restrooms', 'Cafe'],
      ),
    ]);

    // Seed Matches
    _matches.addAll([
      MatchRecord(
        id: 'm_101',
        matchCode: 'NPR-712',
        type: MatchType.doubles,
        team1PlayerIds: ['user_pratik', 'p_rohan'],
        team1PlayerNames: ['Pratik Sharma', 'Rohan Shrestha'],
        team2PlayerIds: ['p_bibek', 'p_sujan'],
        team2PlayerNames: ['Bibek Thapa', 'Sujan Maharjan'],
        gameScores: const [
          GameScore(team1Score: 11, team2Score: 8),
          GameScore(team1Score: 11, team2Score: 5),
        ],
        date: DateTime.now().subtract(const Duration(days: 2)),
        loggedByPlayerId: 'user_pratik',
        loggedByPlayerName: 'Pratik Sharma',
        status: MatchVerificationStatus.confirmed,
        ratingDeltaTeam1: 0.125,
        ratingDeltaTeam2: -0.125,
        venueName: 'Tiptoe Pickleball Club (Sanepa)',
      ),
      MatchRecord(
        id: 'm_102',
        matchCode: 'NPR-834',
        type: MatchType.singles,
        team1PlayerIds: ['p_anjali'],
        team1PlayerNames: ['Anjali Tamang'],
        team2PlayerIds: ['user_pratik'],
        team2PlayerNames: ['Pratik Sharma'],
        gameScores: const [
          GameScore(team1Score: 11, team2Score: 9),
          GameScore(team1Score: 8, team2Score: 11),
          GameScore(team1Score: 11, team2Score: 7),
        ],
        date: DateTime.now().subtract(const Duration(hours: 6)),
        loggedByPlayerId: 'p_anjali',
        loggedByPlayerName: 'Anjali Tamang',
        status: MatchVerificationStatus.pendingVerification,
        ratingDeltaTeam1: 0.082,
        ratingDeltaTeam2: -0.082,
        venueName: 'Boudha Pickleball Arena',
      ),
    ]);
  }

  // Auth & Profile actions
  void loginWithEmail(String email, String password) {
    _isLoggedIn = true;
    notifyListeners();
  }

  void loginAsGuest() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required String city,
    required String homeHub,
    required double baselineRating,
  }) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      name: name,
      city: city,
      homeHub: homeHub,
      singlesRating: baselineRating,
      doublesRating: baselineRating + 0.10,
    );
    notifyListeners();
  }

  // Match Logging & Verification Engine
  String logMatch({
    required MatchType type,
    required List<String> team1PlayerIds,
    required List<String> team1PlayerNames,
    required List<String> team2PlayerIds,
    required List<String> team2PlayerNames,
    required List<GameScore> games,
    required String venueName,
  }) {
    final randomCode = 'NPR-${(Random().nextInt(900) + 100)}';
    final matchId = 'm_${DateTime.now().millisecondsSinceEpoch}';

    // Calculate tentative preview deltas
    final team1Avg = _calculateTeamAverage(team1PlayerIds, type == MatchType.doubles);
    final team2Avg = _calculateTeamAverage(team2PlayerIds, type == MatchType.doubles);

    final deltas = RatingAlgorithmService.calculateMatchDeltas(
      team1AvgRating: team1Avg,
      team2AvgRating: team2Avg,
      games: games,
    );

    final newMatch = MatchRecord(
      id: matchId,
      matchCode: randomCode,
      type: type,
      team1PlayerIds: team1PlayerIds,
      team1PlayerNames: team1PlayerNames,
      team2PlayerIds: team2PlayerIds,
      team2PlayerNames: team2PlayerNames,
      gameScores: games,
      date: DateTime.now(),
      loggedByPlayerId: currentUser.id,
      loggedByPlayerName: currentUser.name,
      status: MatchVerificationStatus.pendingVerification,
      ratingDeltaTeam1: deltas.team1Delta,
      ratingDeltaTeam2: deltas.team2Delta,
      venueName: venueName,
    );

    _matches.insert(0, newMatch);
    notifyListeners();
    return randomCode;
  }

  double _calculateTeamAverage(List<String> playerIds, bool isDoubles) {
    if (playerIds.isEmpty) return 2.50;
    double sum = 0;
    for (final id in playerIds) {
      final p = _communityPlayers.firstWhere(
        (cp) => cp.id == id,
        orElse: () => _currentUser ?? _defaultGuestProfile,
      );
      sum += isDoubles ? p.doublesRating : p.singlesRating;
    }
    return sum / playerIds.length;
  }

  /// Confirm match and update ratings dynamically
  void confirmMatch(String matchId) {
    final index = _matches.indexWhere((m) => m.id == matchId);
    if (index == -1) return;

    final match = _matches[index];
    if (match.status == MatchVerificationStatus.confirmed) return;

    // Recalculate deltas with live ratings
    final isDoubles = match.type == MatchType.doubles;
    final team1Avg = _calculateTeamAverage(match.team1PlayerIds, isDoubles);
    final team2Avg = _calculateTeamAverage(match.team2PlayerIds, isDoubles);

    final calc = RatingAlgorithmService.calculateMatchDeltas(
      team1AvgRating: team1Avg,
      team2AvgRating: team2Avg,
      games: match.gameScores,
    );

    // Apply adjustments to players
    _applyDeltasToTeam(match.team1PlayerIds, calc.team1Delta, isDoubles, match, calc.team1Delta > 0);
    _applyDeltasToTeam(match.team2PlayerIds, calc.team2Delta, isDoubles, match, calc.team2Delta > 0);

    // Update match status
    _matches[index] = match.copyWith(
      status: MatchVerificationStatus.confirmed,
      ratingDeltaTeam1: calc.team1Delta,
      ratingDeltaTeam2: calc.team2Delta,
    );

    notifyListeners();
  }

  void _applyDeltasToTeam(
    List<String> playerIds,
    double delta,
    bool isDoubles,
    MatchRecord match,
    bool isWinner,
  ) {
    for (final id in playerIds) {
      if (_currentUser != null && _currentUser!.id == id) {
        final newSingles = isDoubles ? _currentUser!.singlesRating : (_currentUser!.singlesRating + delta);
        final newDoubles = isDoubles ? (_currentUser!.doublesRating + delta) : _currentUser!.doublesRating;
        final newHistory = List<RatingHistoryPoint>.from(_currentUser!.ratingHistory);
        
        final currentActiveRating = isDoubles ? newDoubles : newSingles;
        newHistory.add(RatingHistoryPoint(
          date: DateTime.now(),
          rating: (currentActiveRating * 1000).round() / 1000,
          delta: delta,
          note: '${isWinner ? "Win" : "Loss"} in ${match.matchCode} at ${match.venueName}',
        ));

        final newMatchesPlayed = _currentUser!.matchesPlayed + 1;
        final newWins = isWinner ? _currentUser!.wins + 1 : _currentUser!.wins;
        final newLosses = isWinner ? _currentUser!.losses : _currentUser!.losses + 1;
        final newReliability = RatingAlgorithmService.updateReliabilityIndex(
          _currentUser!.reliabilityScore,
          newMatchesPlayed,
        );

        _currentUser = _currentUser!.copyWith(
          singlesRating: (newSingles * 1000).round() / 1000,
          doublesRating: (newDoubles * 1000).round() / 1000,
          matchesPlayed: newMatchesPlayed,
          wins: newWins,
          losses: newLosses,
          reliabilityScore: newReliability,
          ratingHistory: newHistory,
        );
      }

      // Update in community players list as well
      final cpIndex = _communityPlayers.indexWhere((p) => p.id == id);
      if (cpIndex != -1) {
        final p = _communityPlayers[cpIndex];
        final newS = isDoubles ? p.singlesRating : (p.singlesRating + delta);
        final newD = isDoubles ? (p.doublesRating + delta) : p.doublesRating;
        _communityPlayers[cpIndex] = p.copyWith(
          singlesRating: (newS * 1000).round() / 1000,
          doublesRating: (newD * 1000).round() / 1000,
          matchesPlayed: p.matchesPlayed + 1,
          wins: isWinner ? p.wins + 1 : p.wins,
          losses: isWinner ? p.losses : p.losses + 1,
        );
      }
    }
  }

  /// Dispute match
  void disputeMatch(String matchId, String reason) {
    final index = _matches.indexWhere((m) => m.id == matchId);
    if (index == -1) return;

    _matches[index] = _matches[index].copyWith(
      status: MatchVerificationStatus.disputed,
      disputeReason: reason,
    );
    notifyListeners();
  }

  // Check-in to local court / venue
  void checkInVenue(String venueId) {
    if (_currentCheckedInVenueId == venueId) {
      _currentCheckedInVenueId = null;
    } else {
      _currentCheckedInVenueId = venueId;
    }
    notifyListeners();
  }
}
