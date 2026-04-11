import 'package:unseen_scout/core/types/repo_reponse.type.dart';
import 'package:unseen_scout/core/utils/error_wrapper.dart';
import 'package:unseen_scout/modules/missions/data/models/mission.inputs.dart';
import 'package:unseen_scout/modules/missions/data/models/mission.model.dart';
import 'package:unseen_scout/modules/missions/data/sources/remote_missions_datasource.dart';
import 'package:unseen_scout/modules/missions/domain/entities/mission.entity.dart';
import 'package:unseen_scout/modules/missions/domain/repository/missions_repository.dart';

class MissionsRepositoryImpl implements MissionsRepository {
  final _library = 'Misions Repository';
  final RemoteMissionsDatasource remoteDatasource;

  MissionsRepositoryImpl({required this.remoteDatasource});

  @override
  Stream<RepoResponse<List<MissionEntity>>> watchNearbyMissions(
    NearbyMissionsInput input,
  ) async* {
    yield* ErrorWrapper.stream<RepoResponse<List<MissionEntity>>>(
      () async* {
        await for (final rows in remoteDatasource.watchNearbyMissions(
          input.toMap(),
        )) {
          yield SuccessResponse(
            rows
                .map(
                  (row) => MissionModel.fromMap(
                    row,
                    scoutLat: input.lat,
                    scoutLng: input.lng,
                  ),
                )
                .toList(),
          );
        }
      },
      onError: (_) => FailureResponse('An error occurred. Kindly retry.'),
      library: _library,
      description: 'while streaming nearby missions',
    );
  }
}
