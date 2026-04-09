import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:unseen_scout/core/services/location_service/location_service.dart';
import 'package:unseen_scout/core/utils/toast.dart';
import 'package:unseen_scout/modules/missions/domain/usecases/watch_nearby_missions.usecase.dart';
import 'package:unseen_scout/modules/missions/presentation/models/mission.model.dart';

class RadarController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final _watchUseCase = Get.find<WatchNearbyMissionsUseCase>();
  final _locationService = Get.find<LocationService>();

  // ── Animation ────────────────────────────────────────────────────────────────
  late final AnimationController sweepController;

  // ── State ────────────────────────────────────────────────────────────────────
  final missions = <MissionModel>[].obs;
  final isLoading = true.obs;

  StreamSubscription<dynamic>? _missionsSub;

  // ── Lifecycle ────────────────────────────────────────────────────────────────

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

  // ── Missions stream ──────────────────────────────────────────────────────────

  void _startMissionsStream() {
    final lat = _locationService.latitude;
    final lng = _locationService.longitude;
    if (lat == null || lng == null) return;

    isLoading.value = true;
    _missionsSub?.cancel();

    _missionsSub = _watchUseCase(
      WatchNearbyMissionsInput(lat: lat, lng: lng),
    ).listen(
      (response) {
        response.fold(
          (error) => Toast.error(error.message),
          (entities) {
            final currentLat = _locationService.latitude ?? lat;
            final currentLng = _locationService.longitude ?? lng;
            missions.value = entities
                .map((e) => MissionModel.fromEntity(e, currentLat, currentLng))
                .toList();
          },
        );
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
        Toast.error('Failed to load missions. Kindly retry.');
      },
    );
  }
}
