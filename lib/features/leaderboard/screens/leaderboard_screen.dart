import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/app_state_service.dart';
import '../../auth/models/user_profile.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final appState = AppStateService();
  bool _isDoubles = true;
  String _selectedCategory = 'All Nepal';

  final List<String> _categories = [
    'All Nepal',
    'Kathmandu',
    'Pokhara',
    'Tiptoe Club',
    'Boudha Arena',
    'Dunkmandu',
  ];

  @override
  void initState() {
    super.initState();
    appState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    appState.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final allPlayers = List<UserProfile>.from(appState.communityPlayers);

    final filteredPlayers = allPlayers.where((player) {
      if (_selectedCategory == 'All Nepal') return true;
      if (_selectedCategory == 'Kathmandu') return player.city == 'Kathmandu' || player.city == 'Lalitpur';
      if (_selectedCategory == 'Pokhara') return player.city == 'Pokhara';
      if (_selectedCategory == 'Tiptoe Club') return player.homeHub.contains('Tiptoe');
      if (_selectedCategory == 'Boudha Arena') return player.homeHub.contains('Boudha');
      if (_selectedCategory == 'Dunkmandu') return player.homeHub.contains('Dunkmandu');
      return true;
    }).toList();

    filteredPlayers.sort((a, b) {
      final rA = _isDoubles ? a.doublesRating : a.singlesRating;
      final rB = _isDoubles ? b.doublesRating : b.singlesRating;
      return rB.compareTo(rA);
    });

    final currentUserId = appState.currentUser.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SUPR Rankings'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _isDoubles = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _isDoubles ? const Color(0xFF122347) : Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: _isDoubles ? Border.all(color: AppTheme.brightCyan.withOpacity(0.4)) : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Doubles SUPR',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _isDoubles ? Colors.white : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _isDoubles = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !_isDoubles ? const Color(0xFF122347) : Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: !_isDoubles ? Border.all(color: AppTheme.brightCyan.withOpacity(0.4)) : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Singles SUPR',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: !_isDoubles ? Colors.white : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppTheme.navyHero,
                    backgroundColor: AppTheme.pureWhiteCard,
                    side: BorderSide(color: isSelected ? AppTheme.navyHero : AppTheme.borderSubtle),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textMuted,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 12,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Header line
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PLAYER',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.5),
                ),
                Text(
                  _isDoubles ? 'DOUBLES SUPR' : 'SINGLES SUPR',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.5),
                ),
              ],
            ),
          ),

          // Clean Leaderboard Rows: No Initials Squircle
          Expanded(
            child: filteredPlayers.isEmpty
                ? const Center(
                    child: Text('No ranked players in this category yet.', style: TextStyle(color: AppTheme.textMuted)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    itemCount: filteredPlayers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final player = filteredPlayers[index];
                      final rank = index + 1;
                      final rating = _isDoubles ? player.doublesRating : player.singlesRating;
                      final isCurrentUser = player.id == currentUserId;
                      final rankStr = rank < 10 ? '0$rank' : '$rank';

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                        decoration: BoxDecoration(
                          color: isCurrentUser
                              ? const Color(0xFFF4F7FC)
                              : AppTheme.pureWhiteCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isCurrentUser ? AppTheme.navyHero : AppTheme.borderSubtle,
                            width: isCurrentUser ? 1.5 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isCurrentUser
                                  ? const Color.fromRGBO(10, 20, 40, 0.08)
                                  : const Color.fromRGBO(15, 23, 42, 0.02),
                              blurRadius: isCurrentUser ? 8 : 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Two-digit Rank Number
                            SizedBox(
                              width: 26,
                              child: Text(
                                rankStr,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: _getRankTextColor(rank),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Player Details without Initials Avatar
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        player.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: isCurrentUser ? AppTheme.navyHero : AppTheme.textSlate,
                                        ),
                                      ),
                                      if (isCurrentUser) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppTheme.navyHero,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'YOU',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    '${player.city} • ${player.homeHub.split("(").first.trim()}',
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),

                            // Rating & Record
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  rating.toStringAsFixed(3),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textSlate,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '${player.reliabilityScore}% Rel • ${player.wins}W-${player.losses}L',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: player.reliabilityScore >= 60 ? AppTheme.emeraldWin : AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getRankTextColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFD97706); // Gold
      case 2:
        return const Color(0xFF475569); // Silver
      case 3:
        return const Color(0xFF9A3412); // Bronze
      default:
        return const Color(0xFF94A3B8);
    }
  }
}
