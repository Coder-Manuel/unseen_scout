import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:unseen_scout/core/services/location_service/location_service.dart';
import 'package:unseen_scout/core/utils/toast.dart';
import 'package:unseen_scout/modules/missions/data/models/mission.inputs.dart';
import 'package:unseen_scout/modules/missions/domain/entities/mission.entity.dart';
import 'package:unseen_scout/modules/missions/domain/usecases/nearby_missions.usecase.dart';

class RadarController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final _watchUseCase = Get.find<NearbyMissionsUseCase>();
  final _locationService = Get.find<LocationService>();

  late final AnimationController sweepController;

  List<MissionEntity> missions = <MissionEntity>[].obs;
  final isLoading = true.obs;

  StreamSubscription<dynamic>? _missionsSub;

  @override
  void onInit() {
    super.onInit();

    sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // If the service already has a fix (e.g. user navigated away and back),
    // start the stream right away; otherwise wait for it to become ready.
    if (_locationService.isReady.value) {
      _startMissionsStream();
    } else {
      // Stop showing the loader if the service surfaces a location error.
      ever(_locationService.error, (String? err) {
        if (err != null) isLoading.value = false;
      });
    }

    // Re-start the stream whenever the position is refreshed (every 25 s).
    // This keeps the distance labels and radar positions up-to-date.
    ever(_locationService.isReady, (bool ready) {
      if (ready) _startMissionsStream();
    });

    ever(_locationService.position, (_) {
      if (_locationService.isReady.value) _startMissionsStream();
    });
  }

  @override
  void onClose() {
    _missionsSub?.cancel();
    sweepController.dispose();
    super.onClose();
  }

  void _startMissionsStream() {
    final lat = _locationService.latitude;
    final lng = _locationService.longitude;
    if (lat == null || lng == null) return;

    isLoading.value = true;
    _missionsSub?.cancel();

    _missionsSub = _watchUseCase(NearbyMissionsInput(lat: lat, lng: lng))
        .listen(
          (response) {
            response.fold((error) => Toast.error(error.message), (data) {
              missions = data;
            });
            isLoading.value = false;
          },
          onError: (_) {
            isLoading.value = false;
            Toast.error('Failed to load missions. Kindly retry.');
          },
        );
  }
}
