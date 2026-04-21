import 'package:get/get.dart';
import 'package:unseen_scout/core/entities/user.entity.dart';
import 'package:unseen_scout/core/services/storage_service/storage.service.dart';
import 'package:unseen_scout/core/utils/loader.dart';
import 'package:unseen_scout/core/utils/toast.dart';
import 'package:unseen_scout/modules/auth/domain/usecases/logout.usecase.dart';
import 'package:unseen_scout/modules/auth/presentation/pages/login_page.dart';
import 'package:unseen_scout/modules/user/presentation/controllers/user_controller.dart';

class ProfileController extends GetxController {
  final LogoutUseCase _logoutUseCase;
  final UserController _userController;

  ProfileController({
    required LogoutUseCase logoutUseCase,
    required UserController userController,
  }) : _logoutUseCase = logoutUseCase,
       _userController = userController;

  final biometricsEnabled = false.obs;
  final notificationsEnabled = true.obs;
  final isLoggingOut = false.obs;

  // ── Expose user state from UserController ─────────────────────────────────
  Rx<User?> get currentUser => _userController.currentUser;

  @override
  void onInit() async {
    super.onInit();
    biometricsEnabled.value =
        await StorageService.get<bool>(StorageKeys.biometricsKey) ?? false;
    notificationsEnabled.value =
        await StorageService.get<bool>(StorageKeys.notificationKey) ?? true;

    // Fetch user info if not already loaded.
    if (_userController.currentUser.value == null) {
      _userController.getUserDetails();
    }
  }

  void toggleBiometrics(bool value) {
    biometricsEnabled.value = value;
    StorageService.save<bool>(StorageKeys.biometricsKey, value: value);
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    StorageService.save<bool>(StorageKeys.notificationKey, value: value);
  }

  Future<void> logout() async {
    isLoggingOut.value = true;
    Loader.show();
    final result = await _logoutUseCase();
    Loader.dismiss();
    isLoggingOut.value = false;

    result.fold(
      (err) => Toast.error(err.message),
      (_) => Get.offAllNamed(LoginPage.route),
    );
  }
}
