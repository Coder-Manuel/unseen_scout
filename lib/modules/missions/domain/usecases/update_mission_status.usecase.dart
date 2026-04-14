import 'package:unseen_scout/core/types/repo_reponse.type.dart';
import 'package:unseen_scout/modules/missions/data/models/mission.inputs.dart';
import 'package:unseen_scout/modules/missions/domain/repository/missions_repository.dart';

class UpdateMissionStatusUseCase {
  final MissionsRepository repo;

  UpdateMissionStatusUseCase({required this.repo});

  Future<RepoResponse<void>> call(UpdateMissionStatusInput input) =>
      repo.updateMissionStatus(input);
}
