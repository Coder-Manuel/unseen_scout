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
  Stream<List<Map<String, dynamic>>> watchNearbyMissions(
    Map<String, dynamic> data,
  );

  /// Calls the `accept_mission` RPC which atomically marks the mission as
  /// accepted and sets the calling user as its scout.
  Future<bool> acceptMission(String missionId);

  /// Streams the calling user's currently-accepted mission row.
  /// Emits `null` when the user has no active mission.
  Stream<Map<String, dynamic>?> watchActiveMission();

  /// Updates the mission status (e.g. `completed` or `cancelled`).
  Future<Map<String, dynamic>?> updateMissionStatus({
    required String missionId,
    required String status,
  });
}

class RemoteMissionsDatasourceImpl implements RemoteMissionsDatasource {
  final SupabaseClient client;

  RemoteMissionsDatasourceImpl({required this.client});

  @override
  Stream<List<Map<String, dynamic>>> watchNearbyMissions(
    Map<String, dynamic> data,
  ) {
    log('===== FETCHING NEARBY MISSIONS: $data');
    // Use a broadcast controller so multiple listeners can attach without
    // triggering multiple subscriptions.
    final ctrl = StreamController<List<Map<String, dynamic>>>.broadcast();
    Timer? debounceTimer;
    RealtimeChannel? channel;

    // ── PostGIS fetch ───────────────────────────────────────────────────────
    Future<void> fetchNearby() async {
      if (ctrl.isClosed) return;
      try {
        List raw = await client.rpc('get_missions_within_radius', params: data);

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

  // ── Accept mission ────────────────────────────────────────────────────────

  @override
  Future<bool> acceptMission(String missionId) {
    return client.rpc<bool>(
      'accept_mission',
      params: {'p_mission_id': missionId},
    );
  }

  // ── Watch active mission ──────────────────────────────────────────────────

  @override
  Stream<Map<String, dynamic>?> watchActiveMission() {
    final ctrl = StreamController<Map<String, dynamic>?>.broadcast();
    Timer? debounceTimer;
    RealtimeChannel? channel;

    final userId = client.auth.currentUser?.id;

    Future<void> fetchActive() async {
      if (ctrl.isClosed) return;
      if (userId == null) {
        if (!ctrl.isClosed) ctrl.add(null);
        return;
      }
      try {
        final res = await client
            .from('missions')
            .select()
            .eq('scout_id', userId)
            .eq('status', 'accepted')
            .limit(1)
            .maybeSingle();

        log('=== FETCH: $res');

        if (!ctrl.isClosed) {
          ctrl.add(res != null ? Map<String, dynamic>.from(res) : null);
        }
      } catch (e, stack) {
        MonitorService.report(
          ex: e,
          library: 'missions_datasource',
          description: 'while fetching active mission',
          stack: stack,
        );
        if (!ctrl.isClosed) ctrl.addError(e);
      }
    }

    void debouncedFetch() {
      debounceTimer?.cancel();
      debounceTimer = Timer(const Duration(milliseconds: 300), fetchActive);
    }

    // Listen to changes on rows belonging to this scout.
    if (userId != null) {
      channel = client
          .channel('active_mission_watch_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'missions',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'scout_id',
              value: userId,
            ),
            callback: (_) => debouncedFetch(),
          )
          .subscribe();
    }

    fetchActive();

    ctrl.onCancel = () {
      debounceTimer?.cancel();
      if (channel != null) client.removeChannel(channel);
      ctrl.close();
    };

    return ctrl.stream;
  }

  // ── Update mission status ─────────────────────────────────────────────────
  @override
  Future<Map<String, dynamic>?> updateMissionStatus({
    required String missionId,
    required String status,
  }) {
    return client
        .from('update_mission_status')
        .update({'status': status})
        .eq('id', missionId)
        .select()
        .single();
  }
}
