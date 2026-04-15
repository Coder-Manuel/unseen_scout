import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RemoteStreamDatasource {
  /// Invokes the `livekit-init` edge function with [missionId].
  ///
  /// Returns the raw HTTP status code and response body without interpreting
  /// them.  Status validation and DTO mapping are the repository's concern.
  Future<FunctionResponse> goLive({required String missionId});
}

class RemoteStreamDatasourceImpl implements RemoteStreamDatasource {
  final SupabaseClient client;

  RemoteStreamDatasourceImpl({required this.client});

  @override
  Future<FunctionResponse> goLive({required String missionId}) {
    return client.functions.invoke('go-live', body: {'mission_id': missionId});
  }
}
