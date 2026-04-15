import 'dart:async';

import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:unseen_scout/core/services/storage_service/storage.service.dart';
import 'package:unseen_scout/modules/missions/data/models/mission.model.dart';
import 'package:unseen_scout/modules/missions/domain/entities/mission.entity.dart';
import 'package:unseen_scout/modules/missions/presentation/pages/mission_complete_page.dart';
import 'package:unseen_scout/modules/stream/data/models/stream.inputs.dart';
import 'package:unseen_scout/modules/stream/domain/usecases/go_live.usecase.dart';

class LiveStreamController extends GetxController {
  final GoLiveUseCase _goLiveUseCase;

  LiveStreamController({required GoLiveUseCase goLiveUseCase})
    : _goLiveUseCase = goLiveUseCase;

  late MissionEntity _mission;

  final _room = Room(
    roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
  );

  // ── Observable state ───────────────────────────────────────────────────────

  final isConnecting = true.obs;
  final isLive = false.obs;
  final hasError = false.obs;
  final isMicEnabled = true.obs;
  final isEndingMission = false.obs;
  final elapsedSeconds = 0.obs;
  final videoTrack = Rx<VideoTrack?>(null);
  final scoutName = ''.obs;

  Timer? _elapsedTimer;

  // ── Initialise ────────────────────────────────────────────────────────────

  Future<void> initialize(MissionEntity mission) async {
    _mission = mission;
    await _loadScoutName();

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
          // Connect to the LiveKit room with credentials from the use case.
          await _room.connect(session.url, session.token);

          // Publish camera and microphone tracks.
          await _room.localParticipant?.setCameraEnabled(true);
          await _room.localParticipant?.setMicrophoneEnabled(true);

          // Allow WebRTC track negotiation to settle, then grab the track.
          await Future.delayed(const Duration(milliseconds: 400));
          _refreshVideoTrack();

          // Re-check whenever room state changes (e.g. track published late).
          _room.addListener(_refreshVideoTrack);

          isConnecting.value = false;
          isLive.value = true;
          _startTimer();
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
    isEndingMission.value = true;

    _elapsedTimer?.cancel();
    _room.removeListener(_refreshVideoTrack);
    await _room.disconnect();

    Get.toNamed(
      MissionCompletePage.route,
      // MissionCompletePage expects MissionModel; the underlying runtime
      // object from the DB is always a MissionModel.
      arguments: _mission as MissionModel,
    );
  }

  // ── Computed helpers ──────────────────────────────────────────────────────

  /// Elapsed stream time formatted as `MM:SS` (or `H:MM:SS` after one hour).
  String get elapsedLabel {
    final secs = elapsedSeconds.value;
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    final s = secs % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  // ── Private ───────────────────────────────────────────────────────────────

  void _refreshVideoTrack() {
    final publications = _room.localParticipant?.videoTrackPublications;
    if (publications == null || publications.isEmpty) return;
    final track = publications.first.track;
    if (track != null) {
      videoTrack.value = track;
    }
  }

  void _startTimer() {
    _elapsedTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => elapsedSeconds.value++,
    );
  }

  Future<void> _loadScoutName() async {
    final raw = await StorageService.get<Map>(StorageKeys.userDataKey);
    final first = raw?['first_name'] as String? ?? 'Scout';
    final last = raw?['last_name'] as String? ?? '';
    scoutName.value = '$first $last'.trim();
  }

  @override
  void onClose() {
    _elapsedTimer?.cancel();
    _room.removeListener(_refreshVideoTrack);
    _room.disconnect();
    super.onClose();
  }
}
