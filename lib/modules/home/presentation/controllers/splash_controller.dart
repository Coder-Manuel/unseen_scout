import 'package:get/get.dart';
import 'package:unseen_scout/modules/auth/presentation/pages/login_page.dart';
import 'package:unseen_scout/modules/home/presentation/pages/home_page.dart';
import 'package:unseen_scout/modules/user/presentation/controllers/user_controller.dart';

class SplashController extends GetxController {
  Future<void> checkIfUserIsLoggedIn() async {
    final userCTRL = Get.find<UserController>();
    await Future.delayed(Duration(seconds: 3));
    await userCTRL.getUserDetails();
    final user = userCTRL.currentUser.value;
    if (user != null) {
      return Get.offAllNamed(HomePage.route);
    }

    return Get.offAllNamed(LoginPage.route);
  }
}
