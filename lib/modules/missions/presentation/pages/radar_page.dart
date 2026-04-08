import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unseen_scout/config/colors.dart';
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
          final mapHeight = constraints.maxHeight * 0.70;
          final listHeight = constraints.maxHeight - mapHeight;

          return Column(
            children: [
              // ── Radar map ──────────────────────────────────────────────────
              SizedBox(
                height: mapHeight,
                child: _RadarMap(controller: controller, mapHeight: mapHeight),
              ),

              // ── Missions list ──────────────────────────────────────────────
              Expanded(
                child: _MissionsPanel(
                  listHeight: listHeight,
                  controller: controller,
                ),
              ),
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

  const _RadarMap({required this.controller, required this.mapHeight});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mapWidth = constraints.maxWidth;

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Grid background
            Positioned.fill(
              child: CustomPaint(painter: const RadarGridPainter()),
            ),

            // Rotating sweep
            Positioned.fill(
              child: AnimatedBuilder(
                animation: controller.sweepController,
                builder: (_, __) {
                  final rotation =
                      controller.sweepController.value * 2 * pi - pi / 2;
                  return CustomPaint(
                    painter: RadarSweepPainter(rotation: rotation),
                  );
                },
              ),
            ),

            // Mission markers
            ...controller.missions.map(
              (m) => _positionedMarker(m, mapWidth, mapHeight),
            ),

            // "YOU ARE HERE" badge
            Positioned(left: 18, top: 10, child: _YouAreHereBadge()),
          ],
        );
      },
    );
  }

  Widget _positionedMarker(MissionModel m, double mapWidth, double mapHeight) {
    // Width-only constraint — let the Column size its own height naturally.
    const markerW = 90.0;

    return Positioned(
      left: mapWidth * m.mapX - markerW / 2,
      top: mapHeight * m.mapY - 26, // offset up so dot is at the anchor point
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
  final double listHeight;
  final RadarController controller;

  const _MissionsPanel({required this.listHeight, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              '${controller.missions.length} ACTIVE MISSIONS NEARBY',
              style: const TextStyle(
                color: AppColors.textAccent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: controller.missions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) =>
                  _MissionCard(mission: controller.missions[i]),
            ),
          ),
        ],
      ),
    );
  }
}

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
                    '${mission.type} · ${mission.location}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
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
