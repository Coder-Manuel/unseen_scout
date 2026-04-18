import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unseen_scout/config/colors.dart';
import 'package:unseen_scout/core/utils/size.util.dart';
import 'package:unseen_scout/modules/missions/data/models/mission.model.dart';
import 'package:unseen_scout/modules/missions/domain/entities/mission.entity.dart';
import 'package:unseen_scout/modules/missions/presentation/pages/mission_complete_page.dart';

/// Simple stub rate-mission page — shown after a LiveKit room terminates.
///
/// Pass the finished [MissionEntity] as `Get.arguments`.
class RateMissionPage extends StatefulWidget {
  static const String route = '/rate-mission';

  const RateMissionPage({super.key});

  @override
  State<RateMissionPage> createState() => _RateMissionPageState();
}

class _RateMissionPageState extends State<RateMissionPage> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    final mission = Get.arguments as MissionEntity;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              const Text(
                'How was your mission?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              12.verticalSpace,
              Text(
                'Rate your experience with ${mission.client?.displayName ?? 'the client'}.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              40.verticalSpace,

              // ── Star rating row ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final index = i + 1;
                  final filled = index <= _rating;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        filled ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: filled
                            ? const Color(0xFFFFD700)
                            : AppColors.textSecondary,
                        size: 44,
                      ),
                    ),
                  );
                }),
              ),

              const Spacer(flex: 3),

              ElevatedButton(
                onPressed: _rating == 0
                    ? null
                    : () => Get.offNamed(
                        MissionCompletePage.route,
                        arguments: mission,
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  disabledBackgroundColor: AppColors.primary.withAlpha(80),
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Submit Rating',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),

              12.verticalSpace,

              TextButton(
                onPressed: () => Get.offNamed(
                  MissionCompletePage.route,
                  arguments: mission as MissionModel,
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),

              16.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
