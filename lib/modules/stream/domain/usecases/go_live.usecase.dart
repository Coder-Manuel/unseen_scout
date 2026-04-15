import 'package:unseen_scout/core/types/repo_reponse.type.dart';
import 'package:unseen_scout/core/types/usecase.dart';
import 'package:unseen_scout/modules/stream/data/models/stream.inputs.dart';
import 'package:unseen_scout/modules/stream/domain/entities/livekit_session.entity.dart';
import 'package:unseen_scout/modules/stream/domain/repository/stream_repository.dart';

class GoLiveUseCase extends UseCase<LiveKitSessionEntity, InitStreamInput> {
  final StreamRepository repo;

  GoLiveUseCase({required this.repo});

  @override
  Future<RepoResponse<LiveKitSessionEntity>> call(InitStreamInput input) =>
      repo.goLive(input);
}
