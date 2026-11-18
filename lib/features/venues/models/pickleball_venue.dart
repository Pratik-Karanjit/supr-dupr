class PickleballVenue {
  final String id;
  final String name;
  final String location;
  final String fullAddress;
  final int courtsCount;
  final String surfaceType;
  final String openHours;
  final int activePlayersCount;
  final String contactPhone;
  final List<String> amenities;
  final bool hasLighting;

  const PickleballVenue({
    required this.id,
    required this.name,
    required this.location,
    required this.fullAddress,
    required this.courtsCount,
    required this.surfaceType,
    required this.openHours,
    required this.activePlayersCount,
    required this.contactPhone,
    required this.amenities,
    this.hasLighting = true,
  });

  PickleballVenue copyWith({
    String? id,
    String? name,
    String? location,
    String? fullAddress,
    int? courtsCount,
    String? surfaceType,
    String? openHours,
    int? activePlayersCount,
    String? contactPhone,
    List<String>? amenities,
    bool? hasLighting,
  }) {
    return PickleballVenue(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      fullAddress: fullAddress ?? this.fullAddress,
      courtsCount: courtsCount ?? this.courtsCount,
      surfaceType: surfaceType ?? this.surfaceType,
      openHours: openHours ?? this.openHours,
      activePlayersCount: activePlayersCount ?? this.activePlayersCount,
      contactPhone: contactPhone ?? this.contactPhone,
      amenities: amenities ?? this.amenities,
      hasLighting: hasLighting ?? this.hasLighting,
    );
  }
}
