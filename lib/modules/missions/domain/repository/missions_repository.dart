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
}
