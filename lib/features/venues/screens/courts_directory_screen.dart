import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/app_state_service.dart';
import '../models/pickleball_venue.dart';

class CourtsDirectoryScreen extends StatefulWidget {
  const CourtsDirectoryScreen({super.key});

  @override
  State<CourtsDirectoryScreen> createState() => _CourtsDirectoryScreenState();
}

class _CourtsDirectoryScreenState extends State<CourtsDirectoryScreen> {
  final appState = AppStateService();
  String _searchQuery = '';

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

  void _showVenueDetails(PickleballVenue venue) {
    final isCheckedIn = appState.currentCheckedInVenueId == venue.id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      venue.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textSlate),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppTheme.navyHero),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      venue.fullAddress,
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _courtInfoColumn('Courts', '${venue.courtsCount} Courts', Icons.grid_view_rounded),
                    _courtInfoColumn('Surface', venue.surfaceType.split(' ').first, Icons.layers),
                    _courtInfoColumn('Active', '${venue.activePlayersCount} Players', Icons.group),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Court Amenities:',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textSlate),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: venue.amenities.map((amenity) {
                  return Chip(
                    label: Text(amenity, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppTheme.borderSubtle),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: AppTheme.navyHero),
                  const SizedBox(width: 6),
                  Text('Open Hours: ${venue.openHours}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: AppTheme.emeraldWin),
                  const SizedBox(width: 6),
                  Text('Contact: ${venue.contactPhone}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCheckedIn ? AppTheme.coralLoss : AppTheme.navyHero,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    appState.checkInVenue(venue.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isCheckedIn ? 'Checked out from ${venue.name}' : 'Checked into ${venue.name}!',
                        ),
                      ),
                    );
                  },
                  icon: Icon(isCheckedIn ? Icons.logout : Icons.check_circle),
                  label: Text(isCheckedIn ? 'Check Out from Court' : 'Check In at this Court'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _courtInfoColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppTheme.navyHero),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.textSlate)),
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final venues = appState.venues.where((v) {
      if (_searchQuery.isEmpty) return true;
      return v.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.location.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courts & Hubs'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search courts in Kathmandu, Lalitpur, Pokhara...',
                prefixIcon: Icon(Icons.search, color: AppTheme.navyHero),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
            const SizedBox(height: 14),

            // Venue Cards List
            Expanded(
              child: ListView.separated(
                itemCount: venues.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final venue = venues[index];
                  final isCheckedIn = appState.currentCheckedInVenueId == venue.id;

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showVenueDetails(venue),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.pureWhiteCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCheckedIn ? AppTheme.navyHero : AppTheme.borderSubtle,
                          width: isCheckedIn ? 1.5 : 1.0,
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
                              Expanded(
                                child: Text(
                                  venue.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: AppTheme.textSlate,
                                  ),
                                ),
                              ),
                              if (isCheckedIn)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.navyHero,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'CHECKED IN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 13, color: AppTheme.navyHero),
                              const SizedBox(width: 4),
                              Text(
                                venue.location,
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.sports_tennis, size: 12, color: AppTheme.navyHero),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${venue.courtsCount} Courts',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textSlate),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.emeraldWin.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.circle, size: 7, color: AppTheme.emeraldWin),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${venue.activePlayersCount + (isCheckedIn ? 1 : 0)} Active Players',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.emeraldWin, fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                venue.openHours,
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                              ),
                              const Row(
                                children: [
                                  Text('View Details', style: TextStyle(fontSize: 12, color: AppTheme.navyHero, fontWeight: FontWeight.w800)),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_ios, size: 10, color: AppTheme.navyHero),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
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
