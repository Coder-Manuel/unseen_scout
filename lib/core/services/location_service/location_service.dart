import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unseen_scout/core/utils/error_wrapper.dart';

class LocationService extends GetxService with WidgetsBindingObserver {
  final String _library = 'Location Service';

  LocationService({required SupabaseClient supabaseClient})
    : _supabase = supabaseClient;

  final SupabaseClient _supabase;

  static const _kUpdateInterval = Duration(seconds: 25);
  static const _kLocationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  /// The most recently acquired [Position].  Null until first successful fix.
  final position = Rx<Position?>(null);

  /// [true] once we have a valid position and permissions are granted.
  final isReady = false.obs;

  /// Non-null when something prevents location from working.
  final error = Rx<String?>(null);

  Timer? _periodicTimer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initLocation();
  }

  @override
  void onClose() {
    _stopTimer();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  /// Pause updates when the app is not visible.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (isReady.value) {
          // Immediately refresh on return to foreground, then restart timer.
          _fetchAndSubmit();
          _startTimer();
        }
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _stopTimer();
    }
  }

  double? get latitude => position.value?.latitude;
  double? get longitude => position.value?.longitude;

  Future<void> retryInit() => _initLocation();

  Future<void> _initLocation() async {
    error.value = null;
    isReady.value = false;

    // 1 ── Location services enabled?
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      error.value = 'Location services are disabled.';
      return;
    }

    // 2 ── Permission
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.deniedForever) {
      error.value =
          'Location permission permanently denied. Enable it in Settings.';
      return;
    }
    if (perm == LocationPermission.denied) {
      error.value = 'Location permission denied.';
      return;
    }

    // 3 ── First fix
    final ok = await _fetchAndSubmit();
    if (!ok) return;

    isReady.value = true;
    _startTimer();
  }

  /// Fetches the current position, stores it in [position], and pushes it to
  Future<bool> _fetchAndSubmit() async {
    final isSubmitted = await ErrorWrapper.async<bool>(
      () async {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: _kLocationSettings,
        );
        position.value = pos;
        // await _submitToSupabase(pos);
        return true;
      },
      onError: (_) {
        if (position.value == null) {
          // Only surface an error if we have NO position at all.
          error.value = 'Unable to determine your location.';
        }
        return false;
      },
      library: _library,
      description: 'while fetching user location',
    );

    return isSubmitted!;
  }

  /// Pushes [pos] to the `users` table via the `update_scout_location` RPC so
  /// clients can see the scout's real-time position.
  Future<void> _submitToSupabase(Position pos) async {
    await ErrorWrapper.async(
      () async {
        final userId = _supabase.auth.currentUser?.id;
        if (userId == null) return;

        await _supabase.rpc(
          'update_scout_location',
          params: {
            'scout_id': userId,
            'lat': pos.latitude,
            'lng': pos.longitude,
          },
        );
      },
      library: _library,
      description: 'while updating user location',
    );
  }

  void _startTimer() {
    _stopTimer();
    _periodicTimer = Timer.periodic(_kUpdateInterval, (_) => _fetchAndSubmit());
  }

  void _stopTimer() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }
}
