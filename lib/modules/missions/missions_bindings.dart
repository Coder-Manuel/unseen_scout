import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unseen_scout/modules/missions/data/repositories_impl/missions_repository_impl.dart';
import 'package:unseen_scout/modules/missions/data/sources/remote_missions_datasource.dart';
import 'package:unseen_scout/modules/missions/domain/repository/missions_repository.dart';
import 'package:unseen_scout/modules/missions/domain/usecases/nearby_missions.usecase.dart';
import 'package:unseen_scout/modules/missions/presentation/controllers/radar_controller.dart';

class MissionsBindings extends Bindings {
  @override
  void dependencies() {
    // ── Data layer ────────────────────────────────────────────────────────────
    Get.lazyPut<RemoteMissionsDatasource>(
      () => RemoteMissionsDatasourceImpl(client: Get.find<SupabaseClient>()),
      fenix: true,
    );
    Get.lazyPut<MissionsRepository>(
      () => MissionsRepositoryImpl(
        remoteDatasource: Get.find<RemoteMissionsDatasource>(),
      ),
      fenix: true,
    );

    // ── Use case ──────────────────────────────────────────────────────────────
    Get.lazyPut<NearbyMissionsUseCase>(
      () => NearbyMissionsUseCase(repo: Get.find<MissionsRepository>()),
      fenix: true,
    );

    // ── Controller ────────────────────────────────────────────────────────────
    Get.lazyPut<RadarController>(() => RadarController(), fenix: true);
  }
}
