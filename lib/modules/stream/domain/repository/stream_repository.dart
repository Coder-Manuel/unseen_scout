import 'package:unseen_scout/core/types/repo_reponse.type.dart';
import 'package:unseen_scout/modules/stream/data/models/stream.inputs.dart';
import 'package:unseen_scout/modules/stream/domain/entities/livekit_session.entity.dart';

abstract class StreamRepository {
  /// Invokes the `livekit-init` edge function, validates the response, and
  /// returns the LiveKit credentials needed to connect to the mission room.
  Future<RepoResponse<LiveKitSessionEntity>> goLive(InitStreamInput input);
}
