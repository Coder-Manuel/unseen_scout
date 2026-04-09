import 'package:unseen_scout/core/entities/base.entity.dart';
import 'package:unseen_scout/modules/missions/data/models/enums.dart';

class MissionEntity extends BaseEntity {
  final String? clientId;
  final String? scoutId;
  final String description;
  final String currency;
  final double price;
  final int durationInSec;
  final String address;
  final double latitude;
  final double longitude;
  final MissionStatus status;
  final String? acceptedAt;
  final String? completedAt;

  MissionEntity({
    super.id,
    super.createdAt,
    super.updatedAt,
    this.clientId,
    this.scoutId,
    required this.description,
    required this.currency,
    required this.price,
    required this.durationInSec,
    required this.address,
    this.latitude = 0,
    this.longitude = 0,
    this.status = MissionStatus.pending,
    this.acceptedAt,
    this.completedAt,
  });

  /// Friendly duration string, e.g. "5 min" or "1 hr 30 min".
  String get durationLabel {
    final minutes = durationInSec ~/ 60;
    if (minutes < 60) return '$minutes min';
    final hrs = minutes ~/ 60;
    final rem = minutes % 60;
    return rem > 0 ? '$hrs hr $rem min' : '$hrs hr';
  }
}
