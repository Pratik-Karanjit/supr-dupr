import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/app_state_service.dart';
import '../../../services/rating_algorithm_service.dart';
import '../models/match_record.dart';

class LogMatchScreen extends StatefulWidget {
  final VoidCallback? onMatchLogged;

  const LogMatchScreen({super.key, this.onMatchLogged});

  @override
  State<LogMatchScreen> createState() => _LogMatchScreenState();
}

class _LogMatchScreenState extends State<LogMatchScreen> {
  final appState = AppStateService();
  MatchType _matchType = MatchType.doubles;
  
  String? _partnerId;
  String? _opponent1Id;
  String? _opponent2Id;
  
  final TextEditingController _customOpponent1 = TextEditingController();
  final TextEditingController _customOpponent2 = TextEditingController();
  final TextEditingController _customPartner = TextEditingController();

  List<GameScore> _gameScores = [
    const GameScore(team1Score: 11, team2Score: 9),
    const GameScore(team1Score: 9, team2Score: 11),
    const GameScore(team1Score: 11, team2Score: 7),
  ];

  String _selectedVenue = AppConstants.popularHubs.first;

  @override
  void initState() {
    super.initState();
    final players = appState.communityPlayers.where((p) => p.id != appState.currentUser.id).toList();
    if (players.isNotEmpty) {
      _partnerId = players.first.id;
      if (players.length > 1) _opponent1Id = players[1].id;
      if (players.length > 2) _opponent2Id = players[2].id;
    }
  }

  void _addGame() {
    if (_gameScores.length >= 5) return;
    setState(() {
      _gameScores.add(const GameScore(team1Score: 11, team2Score: 8));
    });
  }

  void _removeGame(int index) {
    if (_gameScores.length <= 1) return;
    setState(() {
      _gameScores.removeAt(index);
    });
  }

  void _updateScore(int index, int t1, int t2) {
    setState(() {
      _gameScores[index] = GameScore(
        team1Score: t1.clamp(0, 30),
        team2Score: t2.clamp(0, 30),
      );
    });
  }

  void _submitMatch() {
    final user = appState.currentUser;
    final isDoubles = _matchType == MatchType.doubles;

    // Team 1
    final List<String> team1Ids = [user.id];
    final List<String> team1Names = [user.name];

    if (isDoubles) {
      if (_partnerId != null) {
        final p = appState.communityPlayers.firstWhere((cp) => cp.id == _partnerId);
        team1Ids.add(p.id);
        team1Names.add(p.name);
      } else {
        final name = _customPartner.text.trim().isNotEmpty ? _customPartner.text.trim() : 'Guest Partner';
        team1Ids.add('custom_partner');
        team1Names.add(name);
      }
    }

    // Team 2
    final List<String> team2Ids = [];
    final List<String> team2Names = [];

    if (_opponent1Id != null) {
      final op1 = appState.communityPlayers.firstWhere((cp) => cp.id == _opponent1Id);
      team2Ids.add(op1.id);
      team2Names.add(op1.name);
    } else {
      final name = _customOpponent1.text.trim().isNotEmpty ? _customOpponent1.text.trim() : 'Opponent 1';
      team2Ids.add('custom_op1');
      team2Names.add(name);
    }

    if (isDoubles) {
      if (_opponent2Id != null) {
        final op2 = appState.communityPlayers.firstWhere((cp) => cp.id == _opponent2Id);
        team2Ids.add(op2.id);
        team2Names.add(op2.name);
      } else {
        final name = _customOpponent2.text.trim().isNotEmpty ? _customOpponent2.text.trim() : 'Opponent 2';
        team2Ids.add('custom_op2');
        team2Names.add(name);
      }
    }

    final matchCode = appState.logMatch(
      type: _matchType,
      team1PlayerIds: team1Ids,
      team1PlayerNames: team1Names,
      team2PlayerIds: team2Ids,
      team2PlayerNames: team2Names,
      games: _gameScores,
      venueName: _selectedVenue,
    );

    _showMatchCreatedDialog(matchCode);
  }

  void _showMatchCreatedDialog(String matchCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppTheme.emeraldWin),
              SizedBox(width: 8),
              Text(
                'Match Submitted!',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textSlate),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Match logged and ready for opponent verification.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.navyHero,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.navyBorder),
                ),
                child: Column(
                  children: [
                    const Text(
                      'VERIFICATION CODE',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      matchCode,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF00E5FF),
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Share this code with your opponents to confirm scores & adjust SUPR ratings.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onMatchLogged?.call();
              },
              child: const Text('View Verification Queue'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final availablePlayers = appState.communityPlayers
        .where((p) => p.id != appState.currentUser.id)
        .toList();
    final isDoubles = _matchType == MatchType.doubles;

    // Calculate live tentative rating impact preview
    final tentativeCalc = RatingAlgorithmService.calculateMatchDeltas(
      team1AvgRating: 3.50,
      team2AvgRating: 3.65,
      games: _gameScores,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Pickleball Match'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match Type Toggle (Singles vs Doubles)
            Container(
              decoration: BoxDecoration(
                color: AppTheme.pureWhiteCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _matchType = MatchType.doubles),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isDoubles ? AppTheme.navyHero : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.group, size: 18, color: isDoubles ? Colors.white : AppTheme.textMuted),
                            const SizedBox(width: 8),
                            Text(
                              'Doubles (2v2)',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: isDoubles ? Colors.white : AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _matchType = MatchType.singles),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isDoubles ? AppTheme.navyHero : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person, size: 18, color: !isDoubles ? Colors.white : AppTheme.textMuted),
                            const SizedBox(width: 8),
                            Text(
                              'Singles (1v1)',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: !isDoubles ? Colors.white : AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Roster Setup Card (Pure White)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.pureWhiteCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ROSTER SELECTION',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Team 1: You (+ Partner)
                  Row(
                    children: [
                      const Icon(Icons.shield, color: AppTheme.navyHero, size: 17),
                      const SizedBox(width: 8),
                      Text(
                        'Team 1: ${appState.currentUser.name} (You)',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textSlate),
                      ),
                    ],
                  ),
                  if (isDoubles) ...[
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _partnerId,
                      dropdownColor: Colors.white,
                      decoration: const InputDecoration(
                        labelText: 'Select Partner',
                        prefixIcon: Icon(Icons.person_add, color: AppTheme.navyHero),
                      ),
                      items: availablePlayers.map((p) {
                        return DropdownMenuItem(
                          value: p.id,
                          child: Text('${p.name} (${p.doublesRating.toStringAsFixed(2)})'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _partnerId = val),
                    ),
                  ],

                  const SizedBox(height: 14),
                  const Divider(color: AppTheme.borderSubtle),
                  const SizedBox(height: 10),

                  // Team 2: Opponents
                  const Row(
                    children: [
                      Icon(Icons.sports_kabaddi, color: AppTheme.coralLoss, size: 17),
                      SizedBox(width: 8),
                      Text(
                        'Team 2: Opponent(s)',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textSlate),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _opponent1Id,
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: isDoubles ? 'Opponent 1' : 'Select Opponent',
                      prefixIcon: const Icon(Icons.person, color: AppTheme.coralLoss),
                    ),
                    items: availablePlayers.map((p) {
                      return DropdownMenuItem(
                        value: p.id,
                        child: Text('${p.name} (${(isDoubles ? p.doublesRating : p.singlesRating).toStringAsFixed(2)})'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _opponent1Id = val),
                  ),

                  if (isDoubles) ...[
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _opponent2Id,
                      dropdownColor: Colors.white,
                      decoration: const InputDecoration(
                        labelText: 'Opponent 2',
                        prefixIcon: Icon(Icons.person, color: AppTheme.coralLoss),
                      ),
                      items: availablePlayers.map((p) {
                        return DropdownMenuItem(
                          value: p.id,
                          child: Text('${p.name} (${p.doublesRating.toStringAsFixed(2)})'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _opponent2Id = val),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Game Scores Entry (Pure White Card)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.pureWhiteCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'MATCH SCORES (BEST OF 3)',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addGame,
                        icon: const Icon(Icons.add, size: 16, color: AppTheme.navyHero),
                        label: const Text('Add Game', style: TextStyle(color: AppTheme.navyHero, fontSize: 12, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  ...List.generate(_gameScores.length, (index) {
                    final game = _gameScores[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'G${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.textSlate),
                          ),
                          const Spacer(),
                          // Team 1 Stepper
                          _scoreStepper(
                            score: game.team1Score,
                            onChanged: (val) => _updateScore(index, val, game.team2Score),
                            color: AppTheme.emeraldWin,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(':', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textMuted)),
                          ),
                          // Team 2 Stepper
                          _scoreStepper(
                            score: game.team2Score,
                            onChanged: (val) => _updateScore(index, game.team1Score, val),
                            color: AppTheme.coralLoss,
                          ),
                          const Spacer(),
                          if (_gameScores.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.textMuted),
                              onPressed: () => _removeGame(index),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Venue Selector
            DropdownButtonFormField<String>(
              value: AppConstants.popularHubs.contains(_selectedVenue)
                  ? _selectedVenue
                  : AppConstants.popularHubs.first,
              dropdownColor: Colors.white,
              decoration: const InputDecoration(
                labelText: 'Court Location / Venue',
                prefixIcon: Icon(Icons.location_on_outlined, color: AppTheme.navyHero),
              ),
              items: AppConstants.popularHubs.map((venue) {
                return DropdownMenuItem(value: venue, child: Text(venue, style: const TextStyle(fontSize: 13)));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedVenue = val);
              },
            ),

            const SizedBox(height: 14),

            // Live Rating Forecast Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.pureWhiteCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insights_rounded, color: AppTheme.navyHero, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rating Delta Forecast',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textSlate),
                        ),
                        Text(
                          'Differential multiplier: ${tentativeCalc.pointDifferentialFactor}x',
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: tentativeCalc.team1Delta >= 0
                          ? AppTheme.emeraldWin.withOpacity(0.12)
                          : AppTheme.coralLoss.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${tentativeCalc.team1Delta >= 0 ? "+" : ""}${tentativeCalc.team1Delta.toStringAsFixed(3)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: tentativeCalc.team1Delta >= 0 ? AppTheme.emeraldWin : AppTheme.coralLoss,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Submit CTA Button: Deep Navy (#0A1428)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.navyHero,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppTheme.navyBorder),
                  ),
                ),
                onPressed: _submitMatch,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Submit & Generate Verification Code'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _scoreStepper({
    required int score,
    required ValueChanged<int> onChanged,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => onChanged(score - 1),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: const Icon(Icons.remove, size: 14, color: AppTheme.textSlate),
          ),
        ),
        Container(
          width: 34,
          alignment: Alignment.center,
          child: Text(
            '$score',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
        InkWell(
          onTap: () => onChanged(score + 1),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: const Icon(Icons.add, size: 14, color: AppTheme.textSlate),
          ),
        ),
      ],
    );
  }
}
