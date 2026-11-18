import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/app_state_service.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const AuthScreen({super.key, required this.onLoginSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final appState = AppStateService();
  bool _isSignUp = false;

  final TextEditingController _nameController = TextEditingController(text: 'Pratik Sharma');
  final TextEditingController _emailController = TextEditingController(text: 'pratik@pickleballnepal.org');
  final TextEditingController _passwordController = TextEditingController(text: 'password123');

  String _selectedCity = 'Kathmandu';
  String _selectedHub = AppConstants.popularHubs.first;
  double _baselineRating = 2.50;

  void _submit() {
    if (_isSignUp) {
      appState.updateProfile(
        name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Player Nepal',
        city: _selectedCity,
        homeHub: _selectedHub,
        baselineRating: _baselineRating,
      );
    }
    appState.loginWithEmail(_emailController.text, _passwordController.text);
    widget.onLoginSuccess();
  }

  void _guestLogin() {
    appState.loginAsGuest();
    widget.onLoginSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Nepal Pickleball Badge
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppTheme.voltGreen.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.voltGreen, width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.sports_tennis_rounded, size: 42, color: AppTheme.voltGreen),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nepal Pickleball Rating',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Free Community DUPR-Style System for Nepal',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF334155), width: 0.8),
                  ),
                  child: Column(
                    children: [
                      if (_isSignUp) ...[
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Your Name',
                            prefixIcon: Icon(Icons.person, color: AppTheme.voltGreen),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedCity,
                          dropdownColor: AppTheme.surfaceCard,
                          decoration: const InputDecoration(
                            labelText: 'City in Nepal',
                            prefixIcon: Icon(Icons.location_on, color: AppTheme.accentCyan),
                          ),
                          items: AppConstants.nepalCities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCity = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedHub,
                          dropdownColor: AppTheme.surfaceCard,
                          decoration: const InputDecoration(
                            labelText: 'Local Club / Home Court',
                            prefixIcon: Icon(Icons.sports_tennis, color: AppTheme.pickleballYellow),
                          ),
                          items: AppConstants.popularHubs.map((h) => DropdownMenuItem(value: h, child: Text(h, style: const TextStyle(fontSize: 12)))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedHub = val);
                          },
                        ),
                        const SizedBox(height: 12),
                      ],

                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email, color: AppTheme.voltGreen),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock, color: AppTheme.voltGreen),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: Text(_isSignUp ? 'Create Profile & Start' : 'Sign In'),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Toggle Sign In / Sign Up
                      TextButton(
                        onPressed: () => setState(() => _isSignUp = !_isSignUp),
                        child: Text(
                          _isSignUp
                              ? 'Already have a profile? Sign In'
                              : 'New player? Create Profile & Self-Rate',
                          style: const TextStyle(color: AppTheme.voltGreen, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Guest 1-Tap Entry
                OutlinedButton.icon(
                  onPressed: _guestLogin,
                  icon: const Icon(Icons.bolt, color: AppTheme.pickleballYellow),
                  label: const Text('Explore as Guest (1-Tap Demo Mode)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
