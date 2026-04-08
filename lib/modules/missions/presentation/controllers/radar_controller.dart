import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:unseen_scout/modules/missions/presentation/models/mission.model.dart';

class RadarController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final missions = kMockMissions;

  late final AnimationController sweepController;

  @override
  void onInit() {
    super.onInit();
    sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void onClose() {
    sweepController.dispose();
    super.onClose();
  }
}
