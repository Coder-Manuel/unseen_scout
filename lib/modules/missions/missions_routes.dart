import 'package:get/get.dart';
import 'package:unseen_scout/core/routes/app_route.dart';
import 'package:unseen_scout/modules/missions/presentation/pages/mission_complete_page.dart';
import 'package:unseen_scout/modules/missions/presentation/pages/mission_details_page.dart';
import 'package:unseen_scout/modules/missions/presentation/pages/navigation_page.dart';

class MissionsRoutes implements AppRoute {
  @override
  List<GetPage> pages = [
    GetPage(
      name: MissionDetailsPage.route,
      page: () => const MissionDetailsPage(),
    ),
    GetPage(
      name: MissionCompletePage.route,
      page: () => const MissionCompletePage(),
    ),
    GetPage(
      name: NavigationPage.route,
      page: () => const NavigationPage(),
    ),
  ];
}
