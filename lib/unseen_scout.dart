import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unseen_scout/config/theme.dart';
import 'package:unseen_scout/core/routes/app_pages.dart';
import 'package:unseen_scout/core/services/connectivity_service/offline_widget.dart';
import 'package:unseen_scout/modules/auth/presentation/pages/login_page.dart';

class UnSeenScout extends StatelessWidget {
  const UnSeenScout({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'UnSeen Scout',
      showPerformanceOverlay: kProfileMode,
      navigatorKey: Get.key,
      debugShowCheckedModeBanner: false,
      builder: (_, child) => Stack(children: [child!, const OfflineWidget()]),
      getPages: AppPages.routes,
      initialRoute: LoginPage.route,
      theme: AppTheme.dark,
    );
  }
}
