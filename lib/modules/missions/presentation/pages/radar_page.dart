import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unseen_scout/modules/missions/presentation/controllers/radar_controller.dart';
import 'package:unseen_scout/modules/missions/presentation/widgets/available_missions_panel.dart';
import 'package:unseen_scout/modules/missions/presentation/widgets/radar_map.dart';

class RadarPage extends GetView<RadarController> {
  const RadarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder<RadarController>(
        id: controller.missionsBuilder,
        builder: (_) {
          return LayoutBuilder(
            builder: (_, constraints) {
              final mapHeight = constraints.maxHeight * 0.58;

              return Column(
                children: [
                  // ── Radar map ────────────────────────────────────────────────
                  SizedBox(
                    height: mapHeight,
                    child: RadarMap(mapHeight: mapHeight),
                  ),

                  // ── Missions panel ───────────────────────────────────────────
                  Expanded(child: MissionsPanel()),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
