class NearbyMissionsInput {
  final double lat;
  final double lng;
  final double radiusMeters;

  const NearbyMissionsInput({
    required this.lat,
    required this.lng,
    this.radiusMeters = 2000,
  });
}
