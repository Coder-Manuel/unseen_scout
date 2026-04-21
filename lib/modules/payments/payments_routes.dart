import 'package:get/get.dart';
import 'package:unseen_scout/core/routes/app_route.dart';
import 'package:unseen_scout/modules/payments/payments_bindings.dart';
import 'package:unseen_scout/modules/payments/presentation/pages/statements_page.dart';

class PaymentsRoutes implements AppRoute {
  @override
  List<GetPage> pages = [
    GetPage(
      name: StatementsPage.route,
      page: () => const StatementsPage(),
      binding: PaymentsBindings(),
    ),
  ];
}
