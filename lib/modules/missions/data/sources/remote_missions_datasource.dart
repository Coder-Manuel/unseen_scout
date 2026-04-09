import 'dart:async';
import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unseen_scout/core/services/monitor_service/monitor.service.dart';

abstract class RemoteMissionsDatasource {
  /// Returns a live [Stream] that:
  ///   1. Immediately emits all active missions within [radiusMeters] of the
  ///      given position (via the `get_missions_within_radius` PostGIS RPC).
  ///   2. Re-emits whenever any row in the `missions` table changes (inserts,
  ///      updates, deletes) so the list stays fresh in real-time.
  Stream<List<Map<String, dynamic>>> watchNearbyMissions({
    required double lat,
    required double lng,
    double radiusMeters = 2000,
  });
}

class RemoteMissionsDatasourceImpl implements RemoteMissionsDatasource {
  final SupabaseClient client;

  RemoteMissionsDatasourceImpl({required this.client});

  @override
  Stream<List<Map<String, dynamic>>> watchNearbyMissions({
    required double lat,
    required double lng,
    double radiusMeters = 2000,
  }) {
    log('===== FETCHING NEARBY MISSIONS');
    // Use a broadcast controller so multiple listeners can attach without
    // triggering multiple subscriptions.
    final ctrl = StreamController<List<Map<String, dynamic>>>.broadcast();
    Timer? debounceTimer;
    RealtimeChannel? channel;

    // ── PostGIS fetch ───────────────────────────────────────────────────────
    Future<void> fetchNearby() async {
      if (ctrl.isClosed) return;
      try {
        final raw =
            await client.rpc(
                  'get_missions_within_radius',
                  params: {'lat': lat, 'lng': lng, 'radius_m': radiusMeters},
                )
                as List? ??
            [];

        final rows = raw
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        if (!ctrl.isClosed) ctrl.add(rows);
      } catch (e, stack) {
        MonitorService.report(
          ex: e,
          library: 'missions_datasource',
          description: 'while calling get_missions_within_radius RPC',
          stack: stack,
        );
        if (!ctrl.isClosed) ctrl.addError(e);
      }
    }

    // Debounced wrapper — prevents a burst of realtime events from hammering
    // the DB with back-to-back RPC calls.
    void debouncedFetch() {
      debounceTimer?.cancel();
      debounceTimer = Timer(Duration(milliseconds: 300), fetchNearby);
    }

    // ── Realtime subscription ───────────────────────────────────────────────
    // Listen to ALL changes on the missions table (not just status='active')
    // so that transitions away from 'active' (e.g. mission accepted/completed)
    // also trigger a refresh.
    channel = client
        .channel('nearby_missions_watch')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'missions',
          callback: (_) => debouncedFetch(),
        )
        .subscribe();

    // ── Initial fetch ───────────────────────────────────────────────────────
    fetchNearby();

    // ── Cleanup ─────────────────────────────────────────────────────────────
    ctrl.onCancel = () {
      debounceTimer?.cancel();
      client.removeChannel(channel!);
      ctrl.close();
    };

    return ctrl.stream;
  }
}
