import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/app_state_service.dart';
import '../models/match_record.dart';

class VerificationQueueScreen extends StatefulWidget {
  const VerificationQueueScreen({super.key});

  @override
  State<VerificationQueueScreen> createState() => _VerificationQueueScreenState();
}

class _VerificationQueueScreenState extends State<VerificationQueueScreen> {
  final appState = AppStateService();
  final TextEditingController _codeSearchController = TextEditingController();
  int _activeTabIndex = 0; // 0: Pending, 1: Confirmed

  @override
  void initState() {
    super.initState();
    appState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    appState.removeListener(_onStateChange);
    _codeSearchController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _confirmMatch(MatchRecord match) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Confirm Match Score?', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textSlate)),
          content: Text(
            'Confirming match ${match.matchCode} will update official SUPR ratings for all players based on the point differential.\n\nScores: ${match.gameScores.map((g) => "${g.team1Score}-${g.team2Score}").join(", ")}',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.navyHero,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                appState.confirmMatch(match.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppTheme.navyHero,
                    content: Text(
                      'Match ${match.matchCode} confirmed! Official SUPR ratings updated.',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
              child: const Text('Confirm & Update Rating'),
            ),
          ],
        );
      },
    );
  }

  void _disputeMatch(MatchRecord match) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Dispute Match Score', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textSlate)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the reason for disputing this logged score (e.g., incorrect score in Game 2 or wrong partner):',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Third set was 11-9, not 11-7',
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.coralLoss, foregroundColor: Colors.white),
              onPressed: () {
                final reason = reasonController.text.trim().isNotEmpty
                    ? reasonController.text.trim()
                    : 'Score dispute flagged by opponent';
                appState.disputeMatch(match.id, reason);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppTheme.coralLoss,
                    content: Text('Match marked as Disputed for community review.'),
                  ),
                );
              },
              child: const Text('Submit Dispute'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _codeSearchController.text.trim().toUpperCase();
    final allMatches = _activeTabIndex == 0
        ? appState.pendingVerificationMatches
        : appState.confirmedMatches;

    final filteredMatches = query.isEmpty
        ? allMatches
        : allMatches.where((m) => m.matchCode.contains(query)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Queue'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            // Code Search Box
            TextField(
              controller: _codeSearchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Lookup 6-char Match Code (e.g. NPR-834)...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.navyHero),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _codeSearchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 12),

            // Tab Selector
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Center(
                      child: Text('Review Required (${appState.pendingVerificationMatches.length})'),
                    ),
                    selected: _activeTabIndex == 0,
                    selectedColor: AppTheme.navyHero,
                    backgroundColor: AppTheme.pureWhiteCard,
                    side: BorderSide(color: _activeTabIndex == 0 ? AppTheme.navyHero : AppTheme.borderSubtle),
                    labelStyle: TextStyle(
                      color: _activeTabIndex == 0 ? Colors.white : AppTheme.textMuted,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                    onSelected: (val) => setState(() => _activeTabIndex = 0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: Center(
                      child: Text('Confirmed (${appState.confirmedMatches.length})'),
                    ),
                    selected: _activeTabIndex == 1,
                    selectedColor: AppTheme.navyHero,
                    backgroundColor: AppTheme.pureWhiteCard,
                    side: BorderSide(color: _activeTabIndex == 1 ? AppTheme.navyHero : AppTheme.borderSubtle),
                    labelStyle: TextStyle(
                      color: _activeTabIndex == 1 ? Colors.white : AppTheme.textMuted,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                    onSelected: (val) => setState(() => _activeTabIndex = 1),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // List of Matches
            Expanded(
              child: filteredMatches.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _activeTabIndex == 0 ? Icons.verified_user_outlined : Icons.history,
                            size: 46,
                            color: AppTheme.textLightMuted,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _activeTabIndex == 0
                                ? 'No pending matches waiting for review.'
                                : 'No confirmed matches found.',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredMatches.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final match = filteredMatches[index];
                        final isPending = match.status == MatchVerificationStatus.pendingVerification;
                        final isDisputed = match.status == MatchVerificationStatus.disputed;

                        return Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: AppTheme.pureWhiteCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDisputed
                                  ? AppTheme.coralLoss.withOpacity(0.6)
                                  : (isPending ? AppTheme.warningAmber.withOpacity(0.5) : AppTheme.borderSubtle),
                            ),
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '#${match.matchCode}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.navyHero,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    match.venueName,
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Teams & Scores
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          match.team1PlayerNames.join(' & '),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                            color: match.isTeam1OverallWinner ? AppTheme.textSlate : AppTheme.textMuted,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        const Text('vs', style: TextStyle(color: AppTheme.textLightMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 3),
                                        Text(
                                          match.team2PlayerNames.join(' & '),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                            color: !match.isTeam1OverallWinner ? AppTheme.textSlate : AppTheme.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          match.gameScores.map((g) => '${g.team1Score}-${g.team2Score}').join(' | '),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: AppTheme.textSlate,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Logged by ${match.loggedByPlayerName}',
                                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              if (isDisputed && match.disputeReason != null) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.coralLoss.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.warning_amber_rounded, color: AppTheme.coralLoss, size: 16),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Disputed: ${match.disputeReason}',
                                          style: const TextStyle(color: AppTheme.coralLoss, fontSize: 11, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              if (isPending) ...[
                                const SizedBox(height: 12),
                                const Divider(color: AppTheme.borderSubtle),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _disputeMatch(match),
                                        icon: const Icon(Icons.close_rounded, size: 16, color: AppTheme.coralLoss),
                                        label: const Text('Dispute', style: TextStyle(color: AppTheme.coralLoss)),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.navyHero,
                                          foregroundColor: Colors.white,
                                          elevation: 2,
                                        ),
                                        onPressed: () => _confirmMatch(match),
                                        icon: const Icon(Icons.check_rounded, size: 16),
                                        label: const Text('Confirm Score'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
