import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unseen_scout/core/utils/loader.dart';
import 'package:unseen_scout/core/utils/toast.dart';
import 'package:unseen_scout/modules/missions/domain/entities/mission.entity.dart';
import 'package:unseen_scout/modules/missions/presentation/pages/mission_complete_page.dart';
import 'package:unseen_scout/modules/rating/data/models/rating.input.dart';
import 'package:unseen_scout/modules/rating/domain/usecases/create_rating.usecase.dart';

class RatingController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final CreateRatingUseCase _createRatingUsecase;

  RatingController({required CreateRatingUseCase createRatingUsecase})
    : _createRatingUsecase = createRatingUsecase;

  late final MissionEntity mission;
  late final AnimationController checkCtrl;
  late final Animation<double> checkScale;
  Rx<int> selectedStars = 0.obs;

  Rx<bool> isRating = false.obs;

  String get clientName => mission.client?.displayName ?? 'Client';

  String get paymentText =>
      'Payment of ${mission.currency} ${mission.price.toStringAsFixed(2)} '
      'has been released to $clientName.';

  @override
  void onInit() {
    checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    mission = Get.arguments as MissionEntity;
    checkScale = CurvedAnimation(parent: checkCtrl, curve: Curves.elasticOut);
    // Pop the check icon in on entry.
    checkCtrl.forward();
    super.onInit();
  }

  Future<void> createRating() async {
    if (selectedStars.value <= 0) return onContinue();
    Loader.show(message: 'Posting rating...');
    final response = await _createRatingUsecase(
      CreateRatingInput(
        missionId: mission.id ?? '',
        toUserId: mission.clientId ?? '',
        score: selectedStars.value,
      ),
    );
    Loader.dismiss();

    response.fold((ex) => Toast.error(ex.message), (_) {
      Toast.success('Rating Submitted');
      onContinue();
    });
  }

  void onContinue() =>
      Get.offNamed(MissionCompletePage.route, arguments: mission);

  @override
  void onClose() {
    checkCtrl.dispose();
    super.onClose();
  }
}
