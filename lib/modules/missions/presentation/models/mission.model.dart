class MissionModel {
  final String id;
  final String type;
  final int price;
  final String location;
  final int distanceMeters;
  final int durationMinutes;
  final String instructions;
  final String clientName;
  final double clientRating;
  final int clientMissions;

  /// Fractional position on the radar map (0.0 – 1.0)
  final double mapX;
  final double mapY;

  const MissionModel({
    required this.id,
    required this.type,
    required this.price,
    required this.location,
    required this.distanceMeters,
    required this.durationMinutes,
    required this.instructions,
    required this.clientName,
    required this.clientRating,
    required this.clientMissions,
    required this.mapX,
    required this.mapY,
  });

  String get formattedPrice => 'KES ${_formatNumber(price)}';
  String get formattedDistance => '${distanceMeters}m away';
  String get formattedDistanceLabel => '${distanceMeters}M AWAY FROM YOUR LOCATION';

  static String _formatNumber(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

final kMockMissions = [
  const MissionModel(
    id: '1',
    type: 'Safety Check',
    price: 2500,
    location: 'Westlands',
    distanceMeters: 400,
    durationMinutes: 10,
    instructions:
        'Walk the block, show the main gate and perimeter. Focus on the compound entrance.',
    clientName: 'Client',
    clientRating: 4.8,
    clientMissions: 23,
    mapX: 0.50,
    mapY: 0.38,
  ),
  const MissionModel(
    id: '2',
    type: 'Property Walk',
    price: 3500,
    location: 'Kileleshwa',
    distanceMeters: 800,
    durationMinutes: 20,
    instructions:
        'Walk the property perimeter and record any visible structural changes.',
    clientName: 'Client',
    clientRating: 4.6,
    clientMissions: 11,
    mapX: 0.67,
    mapY: 0.57,
  ),
  const MissionModel(
    id: '3',
    type: 'Traffic Report',
    price: 4000,
    location: 'Parklands',
    distanceMeters: 1200,
    durationMinutes: 15,
    instructions:
        'Record peak traffic flow at the intersection and note any obstructions.',
    clientName: 'Client',
    clientRating: 4.9,
    clientMissions: 41,
    mapX: 0.77,
    mapY: 0.26,
  ),
  const MissionModel(
    id: '4',
    type: 'Perimeter Scout',
    price: 1800,
    location: 'Ngara',
    distanceMeters: 650,
    durationMinutes: 8,
    instructions:
        'Check and photograph the outer fence line. Note any gaps or damage.',
    clientName: 'Client',
    clientRating: 4.3,
    clientMissions: 7,
    mapX: 0.38,
    mapY: 0.65,
  ),
];
