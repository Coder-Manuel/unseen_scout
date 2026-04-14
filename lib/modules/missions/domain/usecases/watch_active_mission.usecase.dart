import 'package:unseen_scout/core/types/repo_reponse.type.dart';
import 'package:unseen_scout/modules/missions/data/models/mission.inputs.dart';
import 'package:unseen_scout/modules/missions/domain/entities/mission.entity.dart';
import 'package:unseen_scout/modules/missions/domain/repository/missions_repository.dart';

class WatchActiveMissionUseCase {
  final MissionsRepository repo;

  WatchActiveMissionUseCase({required this.repo});

  Stream<RepoResponse<MissionEntity?>> call(WatchActiveMissionInput input) =>
      repo.watchActiveMission(input);
}
