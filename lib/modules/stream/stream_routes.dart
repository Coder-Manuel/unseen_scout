import 'package:get/get.dart';
import 'package:unseen_scout/core/routes/app_route.dart';
import 'package:unseen_scout/modules/stream/presentation/pages/stream_page.dart';
import 'package:unseen_scout/modules/stream/stream_bindings.dart';

class StreamRoutes implements AppRoute {
  @override
  List<GetPage> pages = [
    GetPage(
      name: StreamPage.route,
      page: () => const StreamPage(),
      binding: StreamBindings(),
    ),
  ];
}
