import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unseen_scout/config/colors.dart';
import 'package:unseen_scout/core/services/location_service/location_service.dart';
import 'package:unseen_scout/core/utils/size.util.dart';
import 'package:unseen_scout/modules/missions/presentation/controllers/radar_controller.dart';
import 'package:unseen_scout/modules/missions/presentation/models/mission.model.dart';
import 'package:unseen_scout/modules/missions/presentation/pages/mission_details_page.dart';
import 'package:unseen_scout/modules/missions/presentation/widgets/mission_marker_widget.dart';
import 'package:unseen_scout/modules/missions/presentation/widgets/radar_grid_painter.dart';
import 'package:unseen_scout/modules/missions/presentation/widgets/radar_sweep_painter.dart';

class RadarPage extends GetView<RadarController> {
  const RadarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mapHeight = constraints.maxHeight * 0.58;

          return Column(
            children: [
              // ── Radar map ────────────────────────────────────────────────
              SizedBox(
                height: mapHeight,
                child: _RadarMap(controller: controller, mapHeight: mapHeight),
              ),

              // ── Missions panel ───────────────────────────────────────────
              Expanded(child: _MissionsPanel(controller: controller)),
            ],
          );
        },
      ),
    );
  }
}

// ── Radar map ──────────────────────────────────────────────────────────────────
class _RadarMap extends StatelessWidget {
  final RadarController controller;
  final double mapHeight;

  // Location service is global — read it directly here so the map can show
  // permission errors / retry without coupling RadarController to location.
  final _location = Get.find<LocationService>();

  _RadarMap({required this.controller, required this.mapHeight});

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
            Obx(() {
              final list = controller.missions;
              return Stack(
                children: list
                    .map((m) => _positionedMarker(m, mapWidth, mapHeight))
                    .toList(),
              );
            }),

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

  Widget _positionedMarker(MissionModel m, double mapWidth, double mapHeight) {
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

// ── Missions list panel ────────────────────────────────────────────────────────
class _MissionsPanel extends StatelessWidget {
  final RadarController controller;

  const _MissionsPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Obx(() {
        final all = controller.missions;
        // Show at most 4 missions in the bottom list per design
        final preview = all.take(4).toList();
        final count = all.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                count == 0
                    ? 'NO ACTIVE MISSIONS NEARBY'
                    : '$count ACTIVE MISSION${count == 1 ? '' : 'S'} NEARBY',
                style: const TextStyle(
                  color: AppColors.textAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // List or empty placeholder
            Expanded(
              child: controller.isLoading.value
                  ? const _LoadingShimmer()
                  : preview.isEmpty
                  ? const _NoMissionsPlaceholder()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: preview.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _MissionCard(mission: preview[i]),
                    ),
            ),
          ],
        );
      }),
    );
  }
}

// ── No missions placeholder ───────────────────────────────────────────────────
class _NoMissionsPlaceholder extends StatelessWidget {
  const _NoMissionsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
            ),
            child: const Icon(
              Icons.radar_outlined,
              color: AppColors.textSecondary,
              size: 28,
            ),
          ),
          16.verticalSpace,
          const Text(
            'No missions nearby',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          8.verticalSpace,
          const Text(
            'New missions will appear here\nas they become available.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Loading shimmer ───────────────────────────────────────────────────────────
class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, _) => Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

// ── Mission card ──────────────────────────────────────────────────────────────
class _MissionCard extends StatelessWidget {
  final MissionModel mission;

  const _MissionCard({required this.mission});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(MissionDetailsPage.route, arguments: mission),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.location.isNotEmpty
                        ? '${mission.type} · ${mission.location}'
                        : mission.type,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  6.verticalSpace,
                  Text(
                    mission.formattedDistance,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            16.horizontalSpace,
            Text(
              mission.formattedPrice,
              style: const TextStyle(
                color: AppColors.textAccent,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
