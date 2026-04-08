import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unseen_scout/config/env.dart';
import 'package:unseen_scout/core/bindings/initial_binding.dart';
import 'package:unseen_scout/core/services/storage_service/storage.service.dart';
import 'package:unseen_scout/firebase_options.dart';
import 'package:unseen_scout/modules/auth/auth_bindings.dart';
import 'package:unseen_scout/modules/home/home_bindings.dart';
import 'package:unseen_scout/modules/missions/missions_bindings.dart';
import 'package:unseen_scout/modules/user/user_bindings.dart';

import 'services/analytics_service/analytics_service.dart';
import 'services/monitor_service/monitor.service.dart';

class Initializer {
  /// Docs for injecting services [Future]
  static Future<void> _injectServices() async {
    InitialBinding().dependencies();
    AuthBindings().dependencies();
    HomeBindings().dependencies();
    MissionsBindings().dependencies();
    UserBindings().dependencies();
  }

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    Env.init();
    await MonitorService.init();
    await StorageService.init();
    await AnalyticsService.init();
    await Supabase.initialize(
      url: Env.supabaseURL,
      anonKey: Env.supabaseAnonKey,
    );

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    await _injectServices();
  }
}
