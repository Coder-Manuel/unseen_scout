import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_mapbox_navigation_plus/flutter_mapbox_navigation_plus.dart';
import 'package:get/get.dart';
import 'package:unseen_scout/config/colors.dart';
import 'package:unseen_scout/core/services/location_service/location_service.dart';
import 'package:unseen_scout/core/utils/size.util.dart';
import 'package:unseen_scout/modules/missions/domain/entities/mission.entity.dart';

/// Full-screen turn-by-turn navigation page powered by Mapbox Navigation SDK.
///
/// Pass the target [MissionEntity] as `Get.arguments`.
///
/// Flow:
///   1. Page appears → shows "Preparing Navigation" loading screen.
///   2. `startNavigation()` launches the native Mapbox Navigation UI on top.
///   3. When the user closes navigation (or arrives), the native UI dismisses
///      and this page automatically pops itself.
class NavigationPage extends StatefulWidget {
  static const String route = '/navigation';

  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  late final MissionEntity _mission;

  /// Tracks whether navigation has been launched (to avoid double-launch on
  /// hot-reload or lifecycle events).
  bool _launched = false;
  bool _hasError = false;
  bool _arrived = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _mission = Get.arguments as MissionEntity;
    // Wait one frame so the loading UI is visible before the system call.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) =>
          Future.delayed(const Duration(seconds: 2), () => _launchNavigation()),
    );
  }

  // ── Navigation launch ─────────────────────────────────────────────────────

  Future<void> _launchNavigation() async {
    if (_launched || !mounted) return;
    _launched = true;

    try {
      final wayPoints = _buildWayPoints();

      final options = MapBoxOptions(
        mode: MapBoxNavigationMode.drivingWithTraffic,
        simulateRoute: true,
        language: 'en',
        units: VoiceUnits.metric,
        enableRefresh: true,
        alternatives: true,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        allowsUTurnAtWayPoints: true,
        animateBuildRoute: true,
        longPressDestinationEnabled: false,
      );

      MapBoxNavigation.instance.registerRouteEventListener(_onRouteEvent);

      // `startNavigation` opens the full-screen Mapbox Navigation UI.
      // The Future resolves only when the user closes/finishes navigation.
      await MapBoxNavigation.instance.startNavigation(
        wayPoints: wayPoints,
        options: options,
      );

      // Navigation ended — go back to the previous screen.
      if (mounted) Get.back();
    } catch (e) {
      log('==== ERROR: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage =
              'Could not start navigation.\nPlease check your connection and try again.';
        });
      }
    }
  }

  Future<void> _onRouteEvent(RouteEvent e) async {
    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        if (progressEvent.arrived == true) log('==== ARRIVED');
        _arrived = progressEvent.arrived ?? false;
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        break;
      case MapBoxEvent.route_build_failed:
        _hasError = true;
        break;
      case MapBoxEvent.navigation_running:
        break;
      case MapBoxEvent.on_arrival:
        _arrived = true;
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        break;
      default:
        break;
    }
    //refresh UI
    setState(() {});
  }

  List<WayPoint> _buildWayPoints() {
    final locationService = Get.find<LocationService>();
    final lat = locationService.latitude;
    final lng = locationService.longitude;

    return [
      // Origin — scout's current position (silent, no announcement)
      if (lat != null && lng != null)
        WayPoint(
          name: 'Current Location',
          latitude: lat,
          longitude: lng,
          isSilent: true,
        ),

      // Destination — mission coordinates
      WayPoint(
        name: _mission.address.isNotEmpty
            ? _mission.address
            : 'Mission Location',
        latitude: _mission.latitude,
        longitude: _mission.longitude,
      ),
    ];
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  _CloseButton(),
                  20.horizontalSpace,
                  const Text(
                    'Navigation',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ───────────────────────────────────────────────────────
            Expanded(
              child: _hasError
                  ? _ErrorBody(
                      message: _errorMessage,
                      onRetry: () {
                        setState(() {
                          _hasError = false;
                          _launched = false;
                        });
                        _launchNavigation();
                      },
                    )
                  : _PreparingBody(mission: _mission),
            ),
          ],
        ),
      ),
    );
  }
}

// ── "Preparing Navigation" body ───────────────────────────────────────────────

class _PreparingBody extends StatefulWidget {
  final MissionEntity mission;
  const _PreparingBody({required this.mission});

  @override
  State<_PreparingBody> createState() => _PreparingBodyState();
}

class _PreparingBodyState extends State<_PreparingBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 0.92,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 2),

        // Animated pin icon
        ScaleTransition(
          scale: _scale,
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withAlpha(20),
              border: Border.all(
                color: AppColors.primary.withAlpha(60),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.navigation_rounded,
              color: AppColors.primary,
              size: 40,
            ),
          ),
        ),

        32.verticalSpace,

        const Text(
          'Preparing Navigation',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),

        12.verticalSpace,

        const Text(
          'Calculating the best route…',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),

        28.verticalSpace,

        // Destination chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.scoutMarker,
                size: 20,
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DESTINATION',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    4.verticalSpace,
                    Text(
                      widget.mission.address.isNotEmpty
                          ? widget.mission.address
                          : 'Mission Location',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              16.horizontalSpace,
              Text(
                widget.mission.distanceFormatted,
                style: const TextStyle(
                  color: AppColors.textAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        28.verticalSpace,

        // Loading dots
        const _LoadingDots(),

        const Spacer(flex: 3),
      ],
    );
  }
}

// ── Error body ────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
          ),
          child: const Icon(
            Icons.map_outlined,
            color: AppColors.textSecondary,
            size: 32,
          ),
        ),
        20.verticalSpace,
        Text(
          message,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        24.verticalSpace,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Retry',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Animated loading dots ─────────────────────────────────────────────────────

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int _activeDot = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _timer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (mounted) setState(() => _activeDot = (_activeDot + 1) % 3);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == _activeDot ? 10 : 7,
          height: i == _activeDot ? 10 : 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == _activeDot
                ? AppColors.primary
                : AppColors.primary.withAlpha(60),
          ),
        );
      }),
    );
  }
}

// ── Close button ──────────────────────────────────────────────────────────────

class _CloseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Attempt to cleanly stop navigation before popping.
        try {
          await MapBoxNavigation.instance.finishNavigation();
        } catch (_) {}
        Get.back();
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.chevron_left,
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),
    );
  }
}
