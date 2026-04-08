import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unseen_scout/config/theme.dart';
import 'package:unseen_scout/core/routes/app_pages.dart';

class UnSeenScout extends StatelessWidget {
  const UnSeenScout({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'UnSeen',
      showPerformanceOverlay: kProfileMode,
      navigatorKey: Get.key,
      debugShowCheckedModeBanner: false,
      getPages: AppPages.routes,
      // initialRoute: LoginPage.route,
      theme: AppTheme.dark,
    );
  }
}
