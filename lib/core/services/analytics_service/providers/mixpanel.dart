import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:unseen_scout/config/env.dart';
import 'package:unseen_scout/core/services/analytics_service/providers/provider_interface.dart';

class MixPanelProvider implements AnalyticsProvider {
  static MixPanelProvider? _instance;
  Mixpanel? _mixpanel;

  MixPanelProvider._internal() {
    _init();
  }

  /// [MixPanelProvider] singleton instance.
  static MixPanelProvider get instance {
    _instance ??= MixPanelProvider._internal();

    return _instance!;
  }

  void _init() async {
    _mixpanel ??= await Mixpanel.init(
      Env.mixpanelToken,
      trackAutomaticEvents: true,
    );
  }

  /// Set the user information.
  @override
  void setUserInfo(Map<String, dynamic> info) {
    _mixpanel?.registerSuperProperties(info);
  }

  /// Register usesr information.
  @override
  Future<void> registerUser(String id) async {
    final distinctId = await _mixpanel?.getDistinctId();

    if (distinctId != id) {
      _mixpanel?.identify(id);
    }

    await _mixpanel?.flush();
  }

  /// Set user information.
  @override
  void setUserProperty({required String prop, dynamic value}) {
    _mixpanel?.getPeople().set(prop, value);
  }

  /// Record a new mixpanel event.
  ///
  /// > * __@param: (required) [String]__ eventName
  ///
  /// > * __@param: [Map<String, dynamic>?]__ properties
  @override
  void trackEvent({
    required String eventName,
    Map<String, dynamic>? properties,
  }) async {
    _mixpanel?.track(eventName, properties: properties);
    await _mixpanel?.flush();
  }
}
