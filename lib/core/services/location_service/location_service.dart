import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unseen_scout/core/services/monitor_service/monitor.service.dart';

/// Global, permanent location service.
///
/// Responsibilities:
///   • Request / check location permissions once.
///   • Fetch the device position immediately on boot.
///   • While the app is **foregrounded**, refresh & submit the position to
///     Supabase every [_kUpdateInterval] (25 seconds).
///   • Pause the timer automatically when the app is backgrounded /
///     suspended, and restart it on resume.
///
/// Consumers read [position], [isReady] and [error] reactively via Obx / ever.
class LocationService extends GetxService with WidgetsBindingObserver {
  LocationService({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Get.find<SupabaseClient>();

  final SupabaseClient _supabase;

  static const _kUpdateInterval = Duration(seconds: 25);
  static const _kLocationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // only emit if moved ≥ 10 m
  );

  // ── Public reactive state ────────────────────────────────────────────────────

  /// The most recently acquired [Position].  Null until first successful fix.
  final position = Rx<Position?>(null);

  /// [true] once we have a valid position and permissions are granted.
  final isReady = false.obs;

  /// Non-null when something prevents location from working.
  final error = Rx<String?>(null);

  // ── Private ──────────────────────────────────────────────────────────────────

  Timer? _periodicTimer;

  // ── Lifecycle ────────────────────────────────────────────────────────────────

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

  // ── Public API ───────────────────────────────────────────────────────────────

  double? get latitude => position.value?.latitude;
  double? get longitude => position.value?.longitude;

  /// Call from UI to re-attempt initialisation after a denial / error.
  Future<void> retryInit() => _initLocation();

  // ── Initialisation ───────────────────────────────────────────────────────────

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
    var perm = await Geolocator.checkPermission();
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
    if (!ok) return; // error already set inside _fetchAndSubmit

    isReady.value = true;
    _startTimer();
  }

  // ── Core fetch + submit ──────────────────────────────────────────────────────

  /// Fetches the current position, stores it in [position], and pushes it to
  /// Supabase.  Returns [true] on success, [false] on failure.
  Future<bool> _fetchAndSubmit() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: _kLocationSettings,
      );
      position.value = pos;
      await _submitToSupabase(pos);
      return true;
    } catch (e, stack) {
      MonitorService.report(
        ex: e,
        library: 'location_service',
        description: 'while fetching current position',
        stack: stack,
      );
      if (position.value == null) {
        // Only surface an error if we have NO position at all.
        error.value = 'Unable to determine your location.';
      }
      return false;
    }
  }

  // ── Supabase submission ──────────────────────────────────────────────────────

  /// Pushes [pos] to the `users` table via the `update_scout_location` RPC so
  /// clients can see the scout's real-time position.
  Future<void> _submitToSupabase(Position pos) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return; // not signed-in yet, skip silently

      await _supabase.rpc(
        'update_scout_location',
        params: {
          'scout_id': userId,
          'lat': pos.latitude,
          'lng': pos.longitude,
        },
      );
    } catch (e, stack) {
      // Non-fatal — location display still works even if the DB update fails.
      MonitorService.report(
        ex: e,
        library: 'location_service',
        description: 'while submitting scout location to Supabase',
        stack: stack,
      );
    }
  }

  // ── Periodic timer ───────────────────────────────────────────────────────────

  void _startTimer() {
    _stopTimer();
    _periodicTimer = Timer.periodic(_kUpdateInterval, (_) => _fetchAndSubmit());
  }

  void _stopTimer() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }
}
