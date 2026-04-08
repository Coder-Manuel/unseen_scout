import 'package:get/get.dart';
import 'package:unseen_scout/modules/missions/presentation/controllers/radar_controller.dart';

class MissionsBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RadarController>(() => RadarController(), fenix: true);
  }
}
