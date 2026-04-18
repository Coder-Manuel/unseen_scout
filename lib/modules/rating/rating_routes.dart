import 'package:get/get.dart';
import 'package:unseen_scout/core/routes/app_route.dart';
import 'package:unseen_scout/modules/rating/presentation/pages/rate_client_page.dart';

class RatingRoutes implements AppRoute {
  @override
  List<GetPage> pages = [
    GetPage(name: RateClientPage.route, page: () => const RateClientPage()),
  ];
}
