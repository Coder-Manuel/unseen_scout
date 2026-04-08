import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unseen_scout/core/services/analytics_service/analytics_service.dart';
import 'package:unseen_scout/core/utils/navigation_middleware/navigation_controller.dart';

typedef OnRouteChange<R extends Route<dynamic>> =
    void Function(Route? route, Route? previousRoute);

class NavigatorMiddleware<R extends Route<dynamic>>
    extends RouteObserver<Route> {
  NavigatorMiddleware();

  final navigationCTRL = Get.find<NavigationController>();
  final AnalyticsService analytics = AnalyticsService.instance;

  @override
  void didPush(Route route, Route? previousRoute) {
    // * Track navigation history
    navigationCTRL.push(route.settings.name);

    // * Log screen view event.
    analytics.trackScreenView(
      currentScreen: route.settings.name,
      previousScreen: previousRoute?.settings.name,
    );

    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    // Track navigation history
    navigationCTRL.remove(route.settings.name);

    // * Log screen view event.
    analytics.trackScreenView(
      currentScreen: previousRoute?.settings.name,
      previousScreen: route.settings.name,
    );

    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    // Track navigation history
    navigationCTRL.replace(
      oldRoute: oldRoute?.settings.name,
      newRoute: newRoute?.settings.name,
    );

    // * Log screen view event.
    analytics.trackScreenView(
      currentScreen: newRoute?.settings.name,
      previousScreen: oldRoute?.settings.name,
    );

    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    // Track navigation history
    navigationCTRL.remove(route.settings.name);

    super.didRemove(route, previousRoute);
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    // Add ios navigation event here.
    super.didStartUserGesture(route, previousRoute);
  }

  @override
  void didStopUserGesture() {
    // Add ios navigation event here.
    super.didStopUserGesture();
  }
}
