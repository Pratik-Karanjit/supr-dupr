import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'services/app_state_service.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/match_logging/screens/log_match_screen.dart';
import 'features/match_logging/screens/verification_queue_screen.dart';
import 'features/leaderboard/screens/leaderboard_screen.dart';
import 'features/venues/screens/courts_directory_screen.dart';
import 'features/auth/screens/auth_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SuprDuprApp());
}

class SuprDuprApp extends StatelessWidget {
  const SuprDuprApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SUPR DUPR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.suprDuprTheme,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
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

  @override
  Widget build(BuildContext context) {
    if (!appState.isLoggedIn) {
      return AuthScreen(onLoginSuccess: () => setState(() {}));
    }

    final pendingCount = appState.pendingVerificationMatches.length;

    final List<Widget> screens = [
      const ProfileScreen(),
      LogMatchScreen(
        onMatchLogged: () {
          setState(() => _currentIndex = 2); // switch to verification queue
        },
      ),
      const VerificationQueueScreen(),
      const LeaderboardScreen(),
      const CourtsDirectoryScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Analytics',
          ),
          const NavigationDestination(
            icon: Icon(Icons.add_circle_outline_rounded),
            selectedIcon: Icon(Icons.add_circle_rounded),
            label: 'Log Match',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              backgroundColor: AppTheme.coralLoss,
              child: const Icon(Icons.verified_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              backgroundColor: AppTheme.coralLoss,
              child: const Icon(Icons.verified_rounded),
            ),
            label: 'Verify',
          ),
          const NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard_rounded),
            label: 'Rankings',
          ),
          const NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on_rounded),
            label: 'Courts',
          ),
        ],
      ),
    );
  }
}
