import 'dart:async';

import '../content/content_service.dart';
import '../data/step_storage.dart';
import 'route_config.dart';
import 'progress_event.dart';

/// Progression logic layer.
///
/// Responsibilities:
/// - distance calculation from steps
/// - route event checks
/// - reward unlock determination
class ProgressEngine {
  ProgressEngine._();
  static final ProgressEngine instance = ProgressEngine._();

  final StreamController<ProgressEvent> _eventsController =
      StreamController<ProgressEvent>.broadcast();
  final Set<String> _emittedMilestones = <String>{};

  Stream<ProgressEvent> get events => _eventsController.stream;

  /// Converts total steps to route distance in km.
  double distanceKmFromSteps(int totalSteps) {
    return stepsToKm(totalSteps);
  }

  /// Applies route progression for a world and unlocks rewards if thresholds are reached.
  ///
  /// Behavior is intentionally identical to previous StepService logic:
  /// - no duplicate rewards
  /// - no progress reset
  /// - same storage keys and unlock flow
  Future<void> processProgress({
    required String worldId,
    required int totalSteps,
  }) async {
    final totalKm = distanceKmFromSteps(totalSteps);
    final world = ContentService.instance.getById(worldId);
    if (world == null) return;
    final progressPercent = world.route.totalDistanceKm > 0
        ? (totalKm / world.route.totalDistanceKm).clamp(0.0, 1.0)
        : 0.0;

    // Emit each cycle so UI can react in real-time.
    _eventsController.add(
      ProgressEvent(
        type: ProgressEvent.progressUpdated,
        worldId: worldId,
        metadata: {
          'totalSteps': totalSteps,
          'distanceKm': totalKm,
          'progressPercent': progressPercent,
        },
      ),
    );

    for (int index = 0; index < world.route.events.length; index++) {
      final event = world.route.events[index];
      final eventId = '${world.route.id}:$index';

      if (totalKm >= event.atKm && !_emittedMilestones.contains('$worldId:$eventId')) {
        _emittedMilestones.add('$worldId:$eventId');
        _eventsController.add(
          ProgressEvent(
            type: ProgressEvent.milestoneReached,
            worldId: worldId,
            metadata: {
              'km': event.atKm,
              'eventId': eventId,
              'text': event.text,
            },
          ),
        );
      }

      final reward = event.reward;
      if (reward == null) continue;

      final alreadyUnlocked = StepStorage.isRewardUnlocked(worldId, reward.id);
      if (alreadyUnlocked) continue;

      if (totalKm >= event.atKm) {
        await StepStorage.unlockReward(worldId, reward.id);
        _eventsController.add(
          ProgressEvent(
            type: ProgressEvent.rewardUnlocked,
            worldId: worldId,
            rewardId: reward.id,
            metadata: {
              'rewardName': reward.name,
              'atKm': event.atKm,
              'totalKm': totalKm,
              'eventId': eventId,
            },
          ),
        );
      }
    }
  }
}
