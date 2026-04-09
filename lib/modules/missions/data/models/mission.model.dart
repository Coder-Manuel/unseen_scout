import 'dart:math';

import 'package:unseen_scout/core/utils/common_functions.dart';
import 'package:unseen_scout/modules/missions/data/models/enums.dart';
import 'package:unseen_scout/modules/missions/domain/entities/mission.entity.dart';

class MissionModel extends MissionEntity {
  MissionModel({
    super.id,
    super.createdAt,
    super.updatedAt,
    super.clientId,
    super.scoutId,
    super.type,
    required super.description,
    required super.currency,
    required super.price,
    required super.durationInSec,
    required super.address,
    super.latitude = 0,
    super.longitude = 0,
    super.distanceMeters = 0,
    super.status = MissionStatus.pending,
    super.mapX,
    super.mapY,
    super.acceptedAt,
    super.completedAt,
  });

  factory MissionModel.fromMap(
    Map<String, dynamic> map, {
    double scoutLat = 0,
    double scoutLng = 0,
  }) {
    final (lat, lng) = _parseLocation(map['location']);
    const scoutMapX = 0.15;
    const scoutMapY = 0.12;
    const mapTotalKm = 4.0; // canvas represents 4 km in each axis

    // Kilometre offsets from scout → mission
    const kmPerDegLat = 111.0;
    final kmPerDegLng = 111.0 * cos(scoutLat * pi / 180);

    final deltaLngKm = (lng - scoutLng) * kmPerDegLng;
    final deltaLatKm = (lat - scoutLat) * kmPerDegLat;

    // Screen Y is inverted relative to latitude
    final mapX = (scoutMapX + deltaLngKm / mapTotalKm).clamp(0.03, 0.95);
    final mapY = (scoutMapY - deltaLatKm / mapTotalKm).clamp(0.03, 0.95);
    final distM = CommonFunctions.haversineMeters(scoutLat, scoutLng, lat, lng);

    return MissionModel(
      id: map['id'] as String?,
      clientId: map['client_id'] as String?,
      scoutId: map['scout_id'] as String?,
      type: map['type'] as String?,
      description: map['description'] as String? ?? '',
      currency: map['currency'] as String? ?? 'KES',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      durationInSec: (map['duration_in_sec'] as num?)?.toInt() ?? 0,
      address: map['address'] as String? ?? '',
      latitude: lat,
      longitude: lng,
      distanceMeters: distM.round(),
      mapX: mapX,
      mapY: mapY,
      status: _parseStatus(map['status'] as String?),
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
      acceptedAt: map['accepted_at'] as String?,
      completedAt: map['completed_at'] as String?,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Parses the Supabase `geography` column.
  /// Supabase REST returns geography as GeoJSON:
  ///   `{"type":"Point","coordinates":[longitude, latitude]}`
  static (double lat, double lng) _parseLocation(dynamic raw) {
    if (raw == null) return (0.0, 0.0);

    if (raw is Map) {
      final coords = raw['coordinates'];
      if (coords is List && coords.length >= 2) {
        // GeoJSON order: [longitude, latitude]
        return ((coords[1] as num).toDouble(), (coords[0] as num).toDouble());
      }
    }

    // Fallback for plain string representations
    return (0.0, 0.0);
  }

  static MissionStatus _parseStatus(String? s) => switch (s) {
    'active' => MissionStatus.active,
    'completed' => MissionStatus.completed,
    'cancelled' => MissionStatus.cancelled,
    _ => MissionStatus.pending,
  };

  @override
  int get distanceMeters => throw UnimplementedError();
}
