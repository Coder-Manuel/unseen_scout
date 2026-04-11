import 'dart:math';

import 'package:unseen_scout/core/utils/common_functions.dart';
import 'package:unseen_scout/core/utils/ewkb_parser.dart';
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
    super.status = MissionStatus.open,
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
    final (:latitude, :longitude) = EwkbParser.parsePoint(
      map['location']?.toString(),
    );
    const scoutMapX = 0.15;
    const scoutMapY = 0.12;
    const mapTotalKm = 4.0; // canvas represents 4 km in each axis

    // Kilometre offsets from scout → mission
    const kmPerDegLat = 111.0;
    final kmPerDegLng = 111.0 * cos(scoutLat * pi / 180);

    final deltaLngKm = (latitude - scoutLng) * kmPerDegLng;
    final deltaLatKm = (longitude - scoutLat) * kmPerDegLat;

    // Screen Y is inverted relative to latitude
    final mapX = (scoutMapX + deltaLngKm / mapTotalKm).clamp(0.03, 0.95);
    final mapY = (scoutMapY - deltaLatKm / mapTotalKm).clamp(0.03, 0.95);
    final distM = CommonFunctions.haversineMeters(
      scoutLat,
      scoutLng,
      latitude,
      longitude,
    );

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
      latitude: latitude,
      longitude: longitude,
      distanceMeters: distM.round(),
      mapX: mapX,
      mapY: mapY,
      status: MissionStatus.values.firstWhere(
        (v) => v.name == map['status'],
        orElse: () => MissionStatus.open,
      ),
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
      acceptedAt: map['accepted_at'] as String?,
      completedAt: map['completed_at'] as String?,
    );
  }
}
