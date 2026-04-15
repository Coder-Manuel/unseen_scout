import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unseen_scout/modules/stream/data/repositories_impl/stream_repository_impl.dart';
import 'package:unseen_scout/modules/stream/data/sources/remote_stream_datasource.dart';
import 'package:unseen_scout/modules/stream/domain/repository/stream_repository.dart';
import 'package:unseen_scout/modules/stream/domain/usecases/go_live.usecase.dart';
import 'package:unseen_scout/modules/stream/presentation/controllers/live_stream_controller.dart';

class StreamBindings extends Bindings {
  @override
  void dependencies() {
    // ── Data layer ────────────────────────────────────────────────────────────
    Get.lazyPut<RemoteStreamDatasource>(
      () => RemoteStreamDatasourceImpl(client: Get.find<SupabaseClient>()),
      fenix: true,
    );
    Get.lazyPut<StreamRepository>(
      () => StreamRepositoryImpl(
        remoteDatasource: Get.find<RemoteStreamDatasource>(),
      ),
      fenix: true,
    );

    // ── Use cases ─────────────────────────────────────────────────────────────
    Get.lazyPut<GoLiveUseCase>(
      () => GoLiveUseCase(repo: Get.find<StreamRepository>()),
      fenix: true,
    );

    // ── Controller ────────────────────────────────────────────────────────────
    Get.lazyPut<LiveStreamController>(
      () => LiveStreamController(goLiveUseCase: Get.find<GoLiveUseCase>()),
      fenix: true,
    );
  }
}
