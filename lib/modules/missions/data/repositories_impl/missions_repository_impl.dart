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

  @override
  Future<RepoResponse<void>> acceptMission(AcceptMissionInput input) async {
    final response = await ErrorWrapper.async<RepoResponse<void>>(
      () async {
        final res = await remoteDatasource.acceptMission(input.missionId);
        if (!res) {
          return FailureResponse('Failed to accept mission. Please try again.');
        }
        return SuccessResponse(null);
      },
      onError: (_) => FailureResponse('An error occurred. Please try again.'),
      library: _library,
      description: 'while accepting mission',
    );

    return response!;
  }

  @override
  Stream<RepoResponse<MissionEntity?>> watchActiveMission(
    WatchActiveMissionInput input,
  ) async* {
    yield* ErrorWrapper.stream<RepoResponse<MissionEntity?>>(
      () async* {
        await for (final row in remoteDatasource.watchActiveMission()) {
          if (row == null) {
            yield SuccessResponse(null);
          } else {
            yield SuccessResponse(
              MissionModel.fromMap(
                row,
                scoutLat: input.scoutLat,
                scoutLng: input.scoutLng,
              ),
            );
          }
        }
      },
      onError: (_) => FailureResponse('Failed to watch active mission.'),
      library: _library,
      description: 'while streaming active mission',
    );
  }

  @override
  Future<RepoResponse<void>> updateMissionStatus(
    UpdateMissionStatusInput input,
  ) async {
    // Use bool sentinel so ErrorWrapper can distinguish success from error
    // (void methods always return null, so null alone is ambiguous).
    final ok = await ErrorWrapper.async<bool>(
      () async {
        await remoteDatasource.updateMissionStatus(
          missionId: input.missionId,
          status: input.status.name,
        );
        return true;
      },
      onError: (_) => false,
      library: _library,
      description: 'while updating mission status',
    );
    if (ok != true) {
      return FailureResponse('Failed to update mission. Please try again.');
    }
    return SuccessResponse(null);
  }
}
