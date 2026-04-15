import 'package:unseen_scout/core/types/repo_reponse.type.dart';
import 'package:unseen_scout/core/utils/error_wrapper.dart';
import 'package:unseen_scout/modules/stream/data/models/livekit_session.model.dart';
import 'package:unseen_scout/modules/stream/data/models/stream.inputs.dart';
import 'package:unseen_scout/modules/stream/data/sources/remote_stream_datasource.dart';
import 'package:unseen_scout/modules/stream/domain/entities/livekit_session.entity.dart';
import 'package:unseen_scout/modules/stream/domain/repository/stream_repository.dart';

class StreamRepositoryImpl implements StreamRepository {
  final _library = 'Stream Repository';
  final RemoteStreamDatasource remoteDatasource;

  StreamRepositoryImpl({required this.remoteDatasource});

  @override
  Future<RepoResponse<LiveKitSessionEntity>> goLive(
    InitStreamInput input,
  ) async {
    final response =
        await ErrorWrapper.async<RepoResponse<LiveKitSessionEntity>>(
          () async {
            final res = await remoteDatasource.goLive(
              missionId: input.missionId,
            );

            if (res.status != 200) {
              return FailureResponse(
                'Stream initialisation failed (HTTP ${res.status}).',
              );
            }

            return SuccessResponse(LiveKitSessionModel.fromMap(res.data));
          },
          onError: (_) => FailureResponse('Failed to initialise stream.'),
          library: _library,
          description: 'while initialising stream',
        );

    return response!;
  }
}
