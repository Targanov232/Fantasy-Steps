import 'dart:io';
import 'package:health/health.dart';
import '../data/step_storage.dart';
import 'world_service.dart';
import 'progress_engine.dart';

class RefreshResult {
  const RefreshResult({
    this.stepsToday,
    this.error,
    this.healthConnectUnavailable = false,
  });

  final int? stepsToday;
  final String? error;
  final bool healthConnectUnavailable;

  bool get isSuccess => error == null && stepsToday != null;
}

class StepService {
  StepService._();
  static final StepService instance = StepService._();

  final List<HealthDataType> _types = [HealthDataType.STEPS];

  static String get _todayString {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  static DateTime get _startOfToday {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  Future<bool> isHealthAvailable() async {
    if (!Platform.isAndroid) return false;
    try {
      final health = Health();
      await health.configure();
      return await health.isHealthConnectAvailable();
    } catch (_) {
      return false;
    }
  }

  Future<bool> hasHealthPermission() async {
    if (!Platform.isAndroid) return false;
    try {
      final health = Health();
      await health.configure();
      return await health.hasPermissions(_types) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestPermission() async {
    if (!Platform.isAndroid) return false;
    try {
      final health = Health();
      await health.configure();
      return await health.requestAuthorization(_types);
    } catch (_) {
      return false;
    }
  }

  /// 🚶 Умное обновление шагов + 🎁 НАГРАДЫ
  Future<RefreshResult> refreshSteps() async {
    if (!Platform.isAndroid) {
      return const RefreshResult(error: 'Only Android is supported');
    }

    if (!StepStorage.isInitialized) {
      return const RefreshResult(error: 'Storage not initialized.');
    }

    try {
      final health = Health();
      await health.configure();

      bool hasPerm = await health.hasPermissions(_types) ?? false;
      if (!hasPerm) {
        hasPerm = await health.requestAuthorization(_types);
        if (!hasPerm) return const RefreshResult(error: 'Permission denied');
      }

      int? stepsFromHealth = await health.getTotalStepsInInterval(
        _startOfToday,
        DateTime.now(),
      );

      if (stepsFromHealth == null) {
        return const RefreshResult(error: 'No steps data available');
      }

      final activeId = WorldService.instance.activeWorldId;

      int lastRecordedToday = StepStorage.getLastRecordedToday(activeId, _todayString);

      int delta = stepsFromHealth - lastRecordedToday;

      if (delta > 0) {
        int currentTotal = StepStorage.getTotalSteps(activeId);
        int newTotal = currentTotal + delta;

        await StepStorage.setTotalSteps(activeId, newTotal);

        await StepStorage.updateTodayProgress(activeId, stepsFromHealth, _todayString);

        // Progression layer (events/rewards).
        await ProgressEngine.instance.processProgress(
          worldId: activeId,
          totalSteps: newTotal,
        );
      } else if (delta < 0) {
        await StepStorage.updateTodayProgress(activeId, stepsFromHealth, _todayString);
      }

      return RefreshResult(stepsToday: stepsFromHealth);
    } catch (e) {
      return RefreshResult(error: 'Failed to read steps: $e');
    }
  }

}