import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unseen_scout/config/colors.dart';
import 'package:unseen_scout/core/services/location_service/location_service.dart';
import 'package:unseen_scout/core/utils/size.util.dart';
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
      builder: (context, constraints) {
        final mapWidth = constraints.maxWidth;

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

            // Mission markers — reactive to the stream
            Stack(
              children: controller.missions
                  .map((m) => _positionedMarker(m, mapWidth, mapHeight))
                  .toList(),
            ),

            // "YOU ARE HERE" badge
            Positioned(left: 18, top: 10, child: _YouAreHereBadge()),

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

  Widget _positionedMarker(MissionEntity m, double mapWidth, double mapHeight) {
    const markerW = 90.0;

    return Positioned(
      key: ValueKey(m.id),
      left: mapWidth * m.mapX - markerW / 2,
      top: mapHeight * m.mapY - 26,
      child: GestureDetector(
        onTap: () => Get.toNamed(MissionDetailsPage.route, arguments: m),
        child: SizedBox(
          width: markerW,
          child: MissionMarkerWidget(price: m.formattedPrice),
        ),
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
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
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
            'YOU ARE HERE',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
