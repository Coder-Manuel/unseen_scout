import 'package:unseen_scout/core/types/repo_reponse.type.dart';
import 'package:unseen_scout/core/utils/error_wrapper.dart';
import 'package:unseen_scout/modules/missions/data/models/mission.model.dart';
import 'package:unseen_scout/modules/missions/data/sources/remote_missions_datasource.dart';
import 'package:unseen_scout/modules/missions/domain/entities/mission.entity.dart';
import 'package:unseen_scout/modules/missions/domain/repository/missions_repository.dart';

class MissionsRepositoryImpl implements MissionsRepository {
  final _library = 'Misions Repository';
  final RemoteMissionsDatasource remoteDatasource;

  MissionsRepositoryImpl({required this.remoteDatasource});

  @override
  Stream<RepoResponse<List<MissionEntity>>> watchNearbyMissions({
    required double lat,
    required double lng,
    double radiusMeters = 2000,
  }) async* {
    ErrorWrapper.stream<RepoResponse<List<MissionEntity>>>(
      () async* {
        await for (final rows in remoteDatasource.watchNearbyMissions(
          lat: lat,
          lng: lng,
          radiusMeters: radiusMeters,
        )) {
          // Rows are already filtered and ordered by Postgres/PostGIS.
          // We only need to hydrate them into domain entities.
          yield SuccessResponse(rows.map(MissionModel.fromMap).toList());
        }
      },
      onError: (_) => FailureResponse('An error occurred. Kindly retry.'),
      library: _library,
      description: 'while streaming nearby missions',
    );
  }
}
