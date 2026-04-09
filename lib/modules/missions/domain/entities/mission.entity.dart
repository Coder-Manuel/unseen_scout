import 'package:unseen_scout/core/entities/base.entity.dart';
import 'package:unseen_scout/modules/missions/data/models/enums.dart';

abstract class MissionEntity extends BaseEntity {
  final String? clientId;
  final String? scoutId;
  final String description;
  final String? type;
  final String currency;
  final double price;
  final int durationInSec;
  final String address;
  final double latitude;
  final double longitude;
  final int distanceMeters;
  final MissionStatus status;
  final double mapX;
  final double mapY;
  final String? acceptedAt;
  final String? completedAt;

  MissionEntity({
    super.id,
    super.createdAt,
    super.updatedAt,
    this.clientId,
    this.scoutId,
    this.type,
    required this.description,
    required this.currency,
    required this.price,
    required this.durationInSec,
    required this.address,
    this.latitude = 0,
    this.longitude = 0,
    this.distanceMeters = 0,
    this.status = MissionStatus.pending,
    this.mapX = 0,
    this.mapY = 0,
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

  String get formattedPrice => '$currency ${_fmt(price)}';
  String _fmt(double n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
