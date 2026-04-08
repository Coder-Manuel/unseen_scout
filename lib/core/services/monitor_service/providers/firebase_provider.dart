import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:unseen_scout/config/env.dart';

/// Service to handle bug reporting
class FirebaseErrorProvider {
  static FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  /// Reports a given bug for analytics
  ///
  ///  [FlutterErrorDetails] => The error details.
  ///
  static Future<bool> report(
    FlutterErrorDetails error, {
    bool isReleaseMode = kReleaseMode,
    bool? isProdEnv,
  }) async {
    bool status = false;

    // * Only report the bugs in release/production mode
    if (isReleaseMode && (isProdEnv ?? Env.isProd)) {
      final StackTrace safeStack =
          (error.stack == null || error.stack.toString().isEmpty)
          ? StackTrace.current
          : error.stack!;

      final flutterError = FlutterErrorDetails(
        exception: error.exception,
        stack: safeStack,
        library: error.library,
        context: error.context,
        informationCollector: error.informationCollector,
        stackFilter: error.stackFilter,
        silent: error.silent,
      );

      // * Report the error to firebase.
      await crashlytics.recordFlutterError(flutterError);

      await crashlytics.sendUnsentReports();

      status = true;
    }

    return status;
  }
}
