import 'package:get/get.dart';
import 'package:unseen_scout/modules/auth/auth_routes.dart';
import 'package:unseen_scout/modules/home/home_routes.dart';
import 'package:unseen_scout/modules/missions/missions_routes.dart';
import 'package:unseen_scout/modules/payments/payments_routes.dart';
import 'package:unseen_scout/modules/rating/rating_routes.dart';
import 'package:unseen_scout/modules/stream/stream_routes.dart';

class AppPages {
  static final List<GetPage> routes = [
    ...AuthRoutes().pages,
    ...HomeRoutes().pages,
    ...MissionsRoutes().pages,
    ...StreamRoutes().pages,
    ...RatingRoutes().pages,
    ...PaymentsRoutes().pages,
  ];
}
