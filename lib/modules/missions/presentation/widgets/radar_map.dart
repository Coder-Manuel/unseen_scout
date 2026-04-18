import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unseen_scout/config/colors.dart';
import 'package:unseen_scout/core/services/location_service/location_service.dart';
import 'package:unseen_scout/core/utils/extensions.dart';
import 'package:unseen_scout/core/utils/size.util.dart';
import 'package:unseen_scout/core/widgets/location_listener.builder.dart';
import 'package:unseen_scout/modules/missions/domain/entities/mission.entity.dart';
import 'package:unseen_scout/modules/missions/presentation/controllers/radar_controller.dart';
import 'package:unseen_scout/modules/missions/presentation/pages/mission_details_page.dart';
import 'package:unseen_scout/modules/missions/presentation/widgets/mission_marker_widget.dart';
import 'package:unseen_scout/modules/missions/presentation/widgets/radar_grid_painter.dart';
import 'package:unseen_scout/modules/missions/presentation/widgets/radar_sweep_painter.dart';

class RadarMap extends GetView<RadarController> {
  final double mapHeight;

  // Location service is global — read it directly here so the map can show
  // permission errors / retry without coupling RadarController to location.
  final _location = Get.find<LocationService>();

  RadarMap({super.key, required this.mapHeight});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final size = Get.mediaQuery.size;

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Grid
            Positioned.fill(
              child: CustomPaint(painter: const RadarGridPainter()),
            ),

            // Rotating sweep
            Positioned.fill(
              child: AnimatedBuilder(
                animation: controller.sweepController,
                builder: (_, _) {
                  final rotation =
                      controller.sweepController.value * 2 * pi - pi / 2;
                  return CustomPaint(
                    painter: RadarSweepPainter(rotation: rotation),
                  );
                },
              ),
            ),

            // Mission markers — hidden when a mission is active
            GetBuilder<RadarController>(
              id: controller.missionsBuilder,
              builder: (_) {
                if (controller.missions.isEmpty) return const SizedBox.shrink();

                final (clat, clng) = _centroid(controller.missions);
                final scale = _scaleFor(
                  controller.missions,
                  clat,
                  clng,
                  size.width,
                  mapHeight,
                );

                // Centre of the "map" viewport
                final cx = size.width * 0.50;
                final cy = mapHeight * 0.50;
                return Stack(
                  children: [
                    for (int i = 0; i < controller.missions.length; i++)
                      Builder(
                        builder: (_) {
                          final m = controller.missions[i];
                          final px = cx + (m.longitude - clng) * scale;
                          // Invert latitude: north is up on screen
                          final py = cy - (m.latitude - clat) * scale;

                          // Clamp so labels don't clip off-screen
                          final clampedX = px.clamp(50.0, size.width - 50.0);
                          final clampedY = py.clamp(60.0, mapHeight - 20.0);

                          return Positioned(
                            left: clampedX - 50, // centre the 18-px dot
                            top: clampedY - 120, // label + gap sit above dot
                            child: GestureDetector(
                              onTap: () => Get.toNamed(
                                MissionDetailsPage.route,
                                arguments: m,
                              ),
                              child: MissionMarkerWidget(
                                price: m.formattedPrice,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            ),

            // "YOU ARE HERE" badge
            Positioned(
              left: size.width * 0.50 - 7,
              top: mapHeight * 0.50 - 7,
              child: _YouAreHereBadge(),
            ),
            // Positioned(left: 18, top: 10, child: _YouAreHereBadge()),

            // Locked overlay — shown while a mission is in progress
            Obx(() {
              if (!controller.hasActiveMission) return const SizedBox.shrink();
              return Positioned.fill(
                child: _LockedRadarOverlay(
                  mission: controller.activeMission.value,
                ),
              );
            }),

            // Loading overlay — shown while acquiring the first fix
            Obx(() {
              if (!controller.isLoading.value) return const SizedBox.shrink();
              return Positioned.fill(
                child: Container(
                  color: AppColors.background.withAlpha(160),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              );
            }),

            // Location error overlay — driven by the global LocationService
            Obx(() {
              final err = _location.error.value;
              if (err == null) return const SizedBox.shrink();
              return Positioned.fill(
                child: Container(
                  color: AppColors.background.withAlpha(200),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_off_outlined,
                        color: AppColors.textSecondary,
                        size: 36,
                      ),
                      12.verticalSpace,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          err,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      16.verticalSpace,
                      TextButton(
                        onPressed: _location.retryInit,
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static (double, double) _centroid(List<MissionEntity> missions) {
    final lat =
        missions.map((m) => m.latitude).reduce((a, b) => a + b) /
        missions.length;
    final lng =
        missions.map((m) => m.longitude).reduce((a, b) => a + b) /
        missions.length;
    return (lat, lng);
  }

  /// Returns a pixels-per-degree scale so the outermost mission sits at ~38 %
  /// of the half-width/half-height of the map area, keeping all dots well
  /// inside the grid and away from the bottom overlay.
  static double _scaleFor(
    List<MissionEntity> missions,
    double clat,
    double clng,
    double mapWidth,
    double mapHeight,
  ) {
    double maxDegOffset = 0.005; // ~550 m minimum to avoid collapsing to center
    for (final m in missions) {
      final dx = (m.longitude - clng).abs();
      final dy = (m.latitude - clat).abs();
      if (dx > maxDegOffset) maxDegOffset = dx;
      if (dy > maxDegOffset) maxDegOffset = dy;
    }

    // Target: farthest mission sits at ~38 % of half-dimension
    final scaleX = (mapWidth * 0.38) / maxDegOffset;
    final scaleY = (mapHeight * 0.38) / maxDegOffset;
    return min(scaleX, scaleY);
  }
}

// ── Locked radar overlay ──────────────────────────────────────────────────────

class _LockedRadarOverlay extends StatelessWidget {
  final MissionEntity? mission;
  const _LockedRadarOverlay({this.mission});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background.withAlpha(180),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.scoutMarker.withAlpha(25),
              border: Border.all(
                color: AppColors.scoutMarker.withAlpha(100),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.scoutMarker,
              size: 26,
            ),
          ),
          14.verticalSpace,
          const Text(
            'RADAR LOCKED',
            style: TextStyle(
              color: AppColors.scoutMarker,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          8.verticalSpace,
          LocationListenerBuilder(
            latitude: mission!.latitude,
            longitude: mission!.longitude,
            builder: (_, distance) {
              return Text(
                mission != null
                    ? 'Mission in progress · ${distance?.formatDistance} away'
                    : 'Complete your current mission\nto scan for new ones.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── "YOU ARE HERE" badge ───────────────────────────────────────────────────────
class _YouAreHereBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(220),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withAlpha(60), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.scoutMarker,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(120),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          8.horizontalSpace,
          const Text(
            'YOU',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
