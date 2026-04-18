import 'dart:async';

import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:unseen_scout/modules/missions/domain/entities/mission.entity.dart';
import 'package:unseen_scout/modules/rating/presentation/pages/rate_client_page.dart';
import 'package:unseen_scout/modules/stream/data/models/stream.inputs.dart';
import 'package:unseen_scout/modules/stream/domain/usecases/go_live.usecase.dart';

/// Lifecycle of the remote client as observed from the LiveKit room.
enum ClientStreamState {
  /// Room connected, but no remote participant yet.
  waiting,

  /// Client present and watching the stream.
  joined,

  /// Client temporarily lost connection (disconnect reason transient).
  disconnected,

  /// Client left the room on their own.
  droppedOff,

  /// Room was terminated server-side — time to navigate away.
  terminated,
}

class LiveStreamController extends GetxController {
  final GoLiveUseCase _goLiveUseCase;

  LiveStreamController({required GoLiveUseCase goLiveUseCase})
    : _goLiveUseCase = goLiveUseCase;

  late MissionEntity mission;

  final _room = Room(
    roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
  );
  EventsListener<RoomEvent>? _roomListener;

  // ── Observable state ───────────────────────────────────────────────────────

  final isConnecting = true.obs;
  final isLive = false.obs;
  final hasError = false.obs;
  final isMicEnabled = true.obs;
  final isEndingMission = false.obs;
  final videoTrack = Rx<VideoTrack?>(null);

  /// Remote client lifecycle.
  final clientState = ClientStreamState.waiting.obs;

  /// Whether the remote client's microphone is currently muted.
  final clientMicMuted = false.obs;

  /// Countdown seconds — seeded from `mission.durationInSec` when the client
  /// first joins.  Starts negative (no timer yet).
  final remainingSeconds = Rx<int?>(null);

  /// True once the countdown hits zero.  Extra seconds beyond zero accumulate
  /// into [exceededSeconds].
  final isExceeded = false.obs;
  final exceededSeconds = 0.obs;

  Timer? _countdownTimer;
  bool _hasNavigatedAway = false;

  // ── Initialise ────────────────────────────────────────────────────────────

  Future<void> initialize(MissionEntity mission) async {
    this.mission = mission;

    final result = await _goLiveUseCase(
      InitStreamInput(missionId: mission.id!),
    );

    await result.fold(
      (err) async {
        isConnecting.value = false;
        hasError.value = true;
      },
      (session) async {
        try {
          // Subscribe to room events BEFORE connecting so we don't miss early
          // participant-joined events.
          _attachRoomListener();

          await _room.connect(session.url, session.token);

          await _room.localParticipant?.setCameraEnabled(true);
          await _room.localParticipant?.setMicrophoneEnabled(true);

          // Allow WebRTC track negotiation to settle, then grab the track.
          await Future.delayed(const Duration(milliseconds: 400));
          _refreshVideoTrack();
          _room.addListener(_refreshVideoTrack);

          // If a remote participant is already in the room (reconnect case),
          // flip state immediately.
          if (_room.remoteParticipants.isNotEmpty) {
            _onClientJoined();
          }

          isConnecting.value = false;
          isLive.value = true;
        } catch (_) {
          isConnecting.value = false;
          hasError.value = true;
        }
      },
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> toggleMic() async {
    final next = !isMicEnabled.value;
    await _room.localParticipant?.setMicrophoneEnabled(next);
    isMicEnabled.value = next;
  }

  Future<void> endMission() async {
    if (isEndingMission.value) return;
    isEndingMission.value = true;

    await _teardown();
    _navigateToRateMission();
  }

  // ── Computed helpers ──────────────────────────────────────────────────────

  /// Main timer label: counts down while active, flips to `+MM:SS` overtime.
  String get timerLabel {
    if (isExceeded.value) return '+${_format(exceededSeconds.value)}';
    final s = remainingSeconds.value;
    if (s == null) return _format(mission.durationInSec);
    return _format(s);
  }

  /// Returns the "Stream ends in Ns" warning string when < 60s remain, else
  /// null so the UI can conditionally render.
  String? get endingSoonLabel {
    final s = remainingSeconds.value;
    if (s == null || s <= 0 || s > 60) return null;
    return 'Stream ends in ${s}s';
  }

  // ── LiveKit event listener ────────────────────────────────────────────────

  void _attachRoomListener() {
    final listener = _room.createListener();
    _roomListener = listener;

    listener
      ..on<ParticipantConnectedEvent>((_) => _onClientJoined())
      ..on<ParticipantDisconnectedEvent>((e) => _onClientLeft(e))
      ..on<TrackMutedEvent>((e) {
        if (e.participant is RemoteParticipant) clientMicMuted.value = true;
      })
      ..on<TrackUnmutedEvent>((e) {
        if (e.participant is RemoteParticipant) clientMicMuted.value = false;
      })
      ..on<RoomDisconnectedEvent>((e) => _onRoomTerminated(e.reason));
  }

  void _onClientJoined() {
    clientState.value = ClientStreamState.joined;
    // Start the mission countdown the first time a client joins.
    if (_countdownTimer == null && !isExceeded.value) {
      _startCountdown();
    }
  }

  void _onClientLeft(ParticipantDisconnectedEvent event) {
    // If other remote participants are still present, treat as "joined".
    if (_room.remoteParticipants.isNotEmpty) return;
    clientState.value = ClientStreamState.droppedOff;
  }

  Future<void> _onRoomTerminated(DisconnectReason? reason) async {
    if (_hasNavigatedAway) return;
    clientState.value = ClientStreamState.terminated;
    await _teardown();
    _navigateToRateMission();
  }

  // ── Countdown timer ───────────────────────────────────────────────────────

  void _startCountdown() {
    remainingSeconds.value = mission.durationInSec;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isExceeded.value) {
        exceededSeconds.value++;
        return;
      }
      final next = (remainingSeconds.value ?? 0) - 1;
      if (next <= 0) {
        remainingSeconds.value = 0;
        isExceeded.value = true;
      } else {
        remainingSeconds.value = next;
      }
    });
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  void _refreshVideoTrack() {
    final publications = _room.localParticipant?.videoTrackPublications;
    if (publications == null || publications.isEmpty) return;
    final track = publications.first.track;
    if (track != null) videoTrack.value = track;
  }

  Future<void> _teardown() async {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _room.removeListener(_refreshVideoTrack);
    await _roomListener?.dispose();
    _roomListener = null;
    await _room.disconnect();
  }

  void _navigateToRateMission() {
    if (_hasNavigatedAway) return;
    _hasNavigatedAway = true;
    Get.offNamed(RateClientPage.route, arguments: mission);
  }

  String _format(int totalSeconds) {
    final secs = totalSeconds.abs();
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    final s = secs % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    _room.removeListener(_refreshVideoTrack);
    _roomListener?.dispose();
    _room.disconnect();
    super.onClose();
  }
}
