import 'package:unseen_scout/modules/missions/data/models/enums.dart';

class NearbyMissionsInput {
  final double lat;
  final double lng;
  final double radiusMeters;

  const NearbyMissionsInput({
    required this.lat,
    required this.lng,
    this.radiusMeters = 2000,
  });

  Map<String, dynamic> toMap() => {
    'lat': lat,
    'lng': lng,
    'radius_m': radiusMeters,
  };
}

class AcceptMissionInput {
  final String missionId;
  const AcceptMissionInput({required this.missionId});
}

class WatchActiveMissionInput {
  final double scoutLat;
  final double scoutLng;
  const WatchActiveMissionInput({this.scoutLat = 0, this.scoutLng = 0});
}

class UpdateMissionStatusInput {
  final String missionId;
  final MissionStatus status;
  const UpdateMissionStatusInput({
    required this.missionId,
    required this.status,
  });
}
