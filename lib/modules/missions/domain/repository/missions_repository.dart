import 'package:unseen_scout/core/types/repo_reponse.type.dart';
import 'package:unseen_scout/modules/missions/data/models/mission.inputs.dart';
import 'package:unseen_scout/modules/missions/domain/entities/mission.entity.dart';

abstract class MissionsRepository {
  /// Opens a realtime stream of active [MissionEntity] objects within
  /// [radiusMeters] of the given coordinates.  Emits a new list every time
  /// the underlying DB changes.
  Stream<RepoResponse<List<MissionEntity>>> watchNearbyMissions(
    NearbyMissionsInput data,
  );

  /// Accepts a mission — sets status to `accepted`, assigns `scout_id` and
  /// records `accepted_at` on the server via the `accept_mission` RPC.
  Future<RepoResponse<void>> acceptMission(AcceptMissionInput input);

  /// Streams the scout's currently accepted mission (null when none active).
  /// Emits a new value whenever the DB row changes (realtime).
  Stream<RepoResponse<MissionEntity?>> watchActiveMission(
    WatchActiveMissionInput input,
  );

  /// Updates a mission's status (e.g. `completed` or `cancelled`).
  Future<RepoResponse<void>> updateMissionStatus(
    UpdateMissionStatusInput input,
  );
}
