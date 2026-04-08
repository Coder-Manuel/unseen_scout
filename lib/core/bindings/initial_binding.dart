import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unseen_scout/core/remote/network_client.dart';
import 'package:unseen_scout/core/services/connectivity_service/connectivity_controller.dart';
import 'package:unseen_scout/core/services/url_launcher_service/url_launcher_service.dart';
import 'package:unseen_scout/core/utils/navigation_middleware/navigation_controller.dart';

class InitialBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    Get.lazyPut<SupabaseClient>(() => Supabase.instance.client, fenix: true);
    Get.lazyPut<Dio>(
      () => NetworkClient.dioClient(baseUrl: ''),
      tag: NetworkDioClientType.global.name,
      fenix: true,
    );

    Get.lazyPut(() => NavigationController(), fenix: true);
    Get.lazyPut<UrlLauncherService>(
      () => UrlLauncherServiceImpl(),
      fenix: true,
    );
    Get.put(
      ConnectivityController(strategy: DefaultObServingStrategy()),
      permanent: true,
    );
  }
}
