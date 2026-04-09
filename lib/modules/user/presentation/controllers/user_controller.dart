import 'package:get/get.dart';
import 'package:unseen_scout/core/entities/user.entity.dart';
import 'package:unseen_scout/core/utils/toast.dart';
import 'package:unseen_scout/modules/user/domain/usecases/get_user_info.usecase.dart';

class UserController extends GetxController {
  final _getUserInfoUsecase = Get.find<GetUserInfoUseCase>();

  Rx<User?> currentUser = Rx<User?>(null);

  Future<void> getUserDetails() async {
    final response = await _getUserInfoUsecase();

    response.fold((ex) => Toast.error(ex.message), (data) {
      currentUser.value = data;
    });
  }
}
