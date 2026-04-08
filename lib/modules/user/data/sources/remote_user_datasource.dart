import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RemoteUserDatasource {
  Future<Map<String, dynamic>?> getUseInfo();
}

class RemoteUserDatasourceImpl extends RemoteUserDatasource {
  final SupabaseClient client;

  RemoteUserDatasourceImpl({required this.client});

  @override
  Future<Map<String, dynamic>?> getUseInfo() {
    return client.rpc('me').single();
  }
}
