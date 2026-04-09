import 'package:unseen_scout/core/types/repo_reponse.type.dart';
import 'package:unseen_scout/modules/missions/domain/entities/mission.entity.dart';
import 'package:unseen_scout/modules/missions/domain/repository/missions_repository.dart';

class WatchNearbyMissionsInput {
  final double lat;
  final double lng;
  final double radiusMeters;

  const WatchNearbyMissionsInput({
    required this.lat,
    required this.lng,
    this.radiusMeters = 2000,
  });
}

/// Stream use-case — not extending [UseCase] because the return type is
/// [Stream] rather than [FutureOr].
class WatchNearbyMissionsUseCase {
  final MissionsRepository repo;

  WatchNearbyMissionsUseCase({required this.repo});

  Stream<RepoResponse<List<MissionEntity>>> call(
    WatchNearbyMissionsInput input,
  ) =>
      repo.watchNearbyMissions(
        lat: input.lat,
        lng: input.lng,
        radiusMeters: input.radiusMeters,
      );
}
