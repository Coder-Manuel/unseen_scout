import 'dart:developer';

enum Environment { staging, prod }

abstract class Env {
  static Environment env = Environment.staging;
  static bool get isProd {
    return env == Environment.prod;
  }

  // ======== Supabase DB Config ============
  static const String supabaseURL = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  static const String mixpanelToken = String.fromEnvironment('MIXPANEL_TOKEN');
  static const String fbIosApiKey = String.fromEnvironment('FB_IOS_API_KEY');
  static const String fbAndroidApiKey = String.fromEnvironment(
    'FB_ANDROID_API_KEY',
  );

  static void init() {
    const envString = String.fromEnvironment('env', defaultValue: 'staging');
    Environment environment = Environment.values.firstWhere(
      (v) => v.name == envString.toLowerCase(),
      orElse: () => Environment.staging,
    );
    env = environment;

    log("==== Env Initialized");
  }
}
