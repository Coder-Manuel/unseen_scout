import 'package:get/get.dart';
import 'package:unseen_scout/modules/auth/auth_routes.dart';

class AppPages {
  static final List<GetPage> routes = [
    ...AuthRoutes().pages,
    // ...HomeRoutes().pages,
    // ...MissionsRoutes().pages,
  ];
}
