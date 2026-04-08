import 'package:get/get.dart';
import 'package:unseen_scout/core/routes/app_route.dart';
import 'package:unseen_scout/modules/home/home_bindings.dart';
import 'package:unseen_scout/modules/home/presentation/pages/home_page.dart';

class HomeRoutes implements AppRoute {
  @override
  List<GetPage> pages = [
    GetPage(
      name: HomePage.route,
      page: () => const HomePage(),
      binding: HomeBindings(),
    ),
  ];
}
