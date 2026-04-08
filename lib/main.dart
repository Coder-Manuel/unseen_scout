import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unseen_scout/core/initializer.dart';
import 'package:unseen_scout/core/services/monitor_service/monitor.service.dart';
import 'package:unseen_scout/unseen_scout.dart';

void main() {
  runZonedGuarded(
    () async {
      // * Init core services/utils
      await Initializer.init();

      runApp(const UnSeenScout());
    },
    (Object ex, StackTrace stack) {
      MonitorService.report(ex: ex, stack: stack, library: 'Main ZoneGuard');
    },
  );
}
