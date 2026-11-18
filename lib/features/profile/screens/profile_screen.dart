import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/app_state_service.dart';
import '../widgets/rating_history_chart.dart';
import '../../match_logging/models/match_record.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showDoubles = true;
  final appState = AppStateService();

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

  void _showEditProfileDialog() {
    final user = appState.currentUser;
    final nameController = TextEditingController(text: user.name);
    String selectedCity = user.city;
    String selectedHub = user.homeHub;
    double baseline = user.singlesRating;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit SUPR DUPR Profile',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textSlate,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppTheme.textMuted),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person, color: AppTheme.navyHero),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: AppConstants.nepalCities.contains(selectedCity)
                        ? selectedCity
                        : AppConstants.nepalCities.first,
                    dropdownColor: Colors.white,
                    decoration: const InputDecoration(
                      labelText: 'City / Location',
                      prefixIcon: Icon(Icons.location_on, color: AppTheme.navyHero),
                    ),
                    items: AppConstants.nepalCities.map((city) {
                      return DropdownMenuItem(value: city, child: Text(city));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedCity = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: AppConstants.popularHubs.contains(selectedHub)
                        ? selectedHub
                        : AppConstants.popularHubs.first,
                    dropdownColor: Colors.white,
                    decoration: const InputDecoration(
                      labelText: 'Home Club / Court Hub',
                      prefixIcon: Icon(Icons.sports_tennis, color: AppTheme.navyHero),
                    ),
                    items: AppConstants.popularHubs.map((hub) {
                      return DropdownMenuItem(value: hub, child: Text(hub, style: const TextStyle(fontSize: 13)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedHub = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Baseline Rating Calibration: ${baseline.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Slider(
                    value: baseline,
                    min: 2.0,
                    max: 5.5,
                    divisions: 35,
                    activeColor: AppTheme.navyHero,
                    onChanged: (val) {
                      setModalState(() => baseline = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.navyHero,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        appState.updateProfile(
                          name: nameController.text.trim(),
                          city: selectedCity,
                          homeHub: selectedHub,
                          baselineRating: baseline,
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = appState.currentUser;
    final userMatches = appState.matches.where((m) =>
      m.team1PlayerIds.contains(user.id) || m.team2PlayerIds.contains(user.id)
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF122347),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.brightCyan.withOpacity(0.4)),
              ),
              child: const Text(
                'SUPR DUPR',
                style: TextStyle(
                  color: Color(0xFF00E5FF),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Player Analytics'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_accounts_outlined, color: Colors.white),
            tooltip: 'Edit Profile',
            onPressed: _showEditProfileDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prominent Hero Rating Card: Deep Navy (#0A1428)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.navyHero, Color(0xFF0F2042)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.navyBorder),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(10, 20, 40, 0.28),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0A1428), Color(0xFF1E3A70)],
                          ),
                          border: Border.all(color: AppTheme.brightCyan, width: 1.5),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.brightCyan.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          user.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 13, color: AppTheme.brightCyan),
                                const SizedBox(width: 3),
                                Text(
                                  '${user.city}, Nepal',
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                ),
                                const SizedBox(width: 8),
                                const Text('•', style: TextStyle(color: Color(0xFF64748B))),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    user.homeHub.split('(').first.trim(),
                                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Dual Tabular Rating Boxes
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => setState(() => _showDoubles = true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: _showDoubles
                                  ? const Color(0xFF122347)
                                  : Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _showDoubles ? AppTheme.brightCyan : Colors.white.withOpacity(0.08),
                                width: _showDoubles ? 1.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'DOUBLES SUPR',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                        color: _showDoubles ? Colors.white : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                    Icon(
                                      Icons.group,
                                      size: 13,
                                      color: _showDoubles ? AppTheme.brightCyan : const Color(0xFF64748B),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.doublesRating.toStringAsFixed(3),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: _showDoubles ? const Color(0xFF00E5FF) : Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => setState(() => _showDoubles = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: !_showDoubles
                                  ? const Color(0xFF122347)
                                  : Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: !_showDoubles ? AppTheme.brightCyan : Colors.white.withOpacity(0.08),
                                width: !_showDoubles ? 1.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'SINGLES SUPR',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                        color: !_showDoubles ? Colors.white : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                    Icon(
                                      Icons.person,
                                      size: 13,
                                      color: !_showDoubles ? AppTheme.brightCyan : const Color(0xFF64748B),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.singlesRating.toStringAsFixed(3),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: !_showDoubles ? const Color(0xFF00E5FF) : Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Reliability Index Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.shield_outlined, color: AppTheme.brightCyan, size: 14),
                                SizedBox(width: 5),
                                Text(
                                  'Reliability Score',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            Text(
                              '${user.reliabilityScore}% (Official)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: user.reliabilityScore / 100.0,
                            minHeight: 6,
                            backgroundColor: Colors.white.withOpacity(0.12),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.brightCyan),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Performance Statistics Row: Pure White Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Matches', '${user.matchesPlayed}'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildRecordCard('${user.wins}W', '${user.losses}L'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard('Win Rate', '${user.winRate.toStringAsFixed(0)}%'),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Dynamic Progress Trajectory Chart
            RatingHistoryChart(
              points: user.ratingHistory,
              isDoubles: _showDoubles,
            ),

            const SizedBox(height: 20),

            // Recent Matches Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Matches',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textSlate,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  '${userMatches.length} Total',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // AUTHENTIC SPORTS MATCH SCORECARD LIST
            if (userMatches.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.pureWhiteCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: const Text(
                  'No matches logged yet. Tap "Log Match" to begin!',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userMatches.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final match = userMatches[index];
                  final isTeam1 = match.team1PlayerIds.contains(user.id);
                  final isUserWinner = isTeam1 ? match.isTeam1OverallWinner : !match.isTeam1OverallWinner;
                  final delta = isTeam1 ? match.ratingDeltaTeam1 : match.ratingDeltaTeam2;
                  final isPending = match.status == MatchVerificationStatus.pendingVerification;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.pureWhiteCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderSubtle),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(15, 23, 42, 0.02),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Meta Header Bar: Clean Venue & Subtle Match ID
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 12, color: AppTheme.navyHero),
                                const SizedBox(width: 4),
                                Text(
                                  match.venueName.split('(').first.trim(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textSlate,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '#${match.matchCode}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textLightMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Team 1 Row
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: match.isTeam1OverallWinner ? AppTheme.emeraldWin : Colors.transparent,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                match.team1PlayerNames.join(' & '),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: match.isTeam1OverallWinner ? FontWeight.w800 : FontWeight.w600,
                                  color: match.isTeam1OverallWinner ? AppTheme.textSlate : AppTheme.textMuted,
                                ),
                              ),
                            ),
                            Row(
                              children: match.gameScores.map((g) {
                                return Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  width: 26,
                                  height: 24,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: g.isTeam1Winner ? const Color(0xFFEDF2F7) : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${g.team1Score}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: g.isTeam1Winner ? FontWeight.w900 : FontWeight.w600,
                                      color: g.isTeam1Winner ? AppTheme.textSlate : AppTheme.textMuted,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Team 2 Row
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: !match.isTeam1OverallWinner ? AppTheme.emeraldWin : Colors.transparent,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                match.team2PlayerNames.join(' & '),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: !match.isTeam1OverallWinner ? FontWeight.w800 : FontWeight.w600,
                                  color: !match.isTeam1OverallWinner ? AppTheme.textSlate : AppTheme.textMuted,
                                ),
                              ),
                            ),
                            Row(
                              children: match.gameScores.map((g) {
                                return Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  width: 26,
                                  height: 24,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: !g.isTeam1Winner ? const Color(0xFFEDF2F7) : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${g.team2Score}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: !g.isTeam1Winner ? FontWeight.w900 : FontWeight.w600,
                                      color: !g.isTeam1Winner ? AppTheme.textSlate : AppTheme.textMuted,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        const Divider(height: 1, color: AppTheme.borderSubtle),
                        const SizedBox(height: 8),

                        // Footer: Rating Delta Chip & Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isPending
                                    ? const Color(0xFFFFFBEB)
                                    : (isUserWinner ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPending
                                        ? Icons.access_time_rounded
                                        : (isUserWinner ? Icons.arrow_outward_rounded : Icons.south_east_rounded),
                                    size: 13,
                                    color: isPending
                                        ? AppTheme.warningAmber
                                        : (isUserWinner ? AppTheme.emeraldWin : AppTheme.coralLoss),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isPending
                                        ? 'Pending SUPR'
                                        : '${delta >= 0 ? "+" : ""}${delta.toStringAsFixed(3)} SUPR',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: isPending
                                          ? AppTheme.warningAmber
                                          : (isUserWinner ? AppTheme.emeraldWin : AppTheme.coralLoss),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              isPending ? 'Awaiting verification' : 'Official match',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.pureWhiteCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppTheme.textSlate,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(String wins, String losses) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.pureWhiteCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                wins,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.emeraldWin,
                ),
              ),
              const Text(' - ', style: TextStyle(color: AppTheme.textLightMuted, fontWeight: FontWeight.bold)),
              Text(
                losses,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.coralLoss,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Record',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
