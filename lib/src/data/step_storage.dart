import 'package:shared_preferences/shared_preferences.dart';

class StepStorage {
  StepStorage._();
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();

    // 🟢 МИГРАЦИЯ (старые шаги → lotr)
    if (_p.containsKey('total_steps') && !_p.containsKey('total_steps_lotr')) {
      int oldSteps = _p.getInt('total_steps') ?? 0;
      await _p.setInt('total_steps_lotr', oldSteps);
      await _p.remove('total_steps');
    }
  }

  static bool get isInitialized => _prefs != null;

  static SharedPreferences get _p {
    if (_prefs == null) throw StateError('StepStorage not initialized');
    return _prefs!;
  }

  // =======================
  // 🔢 STEP KEYS
  // =======================
  static String _keyTotal(String id) => 'total_steps_$id';
  static String _keyLastDate(String id) => 'last_sync_date_$id';
  static String _keyTodayRecorded(String id) => 'steps_today_recorded_$id';

  // =======================
  // 🎁 REWARD KEYS
  // =======================
  static String _keyRewards(String id) => 'unlocked_rewards_$id';

  // =======================
  // 🚶 STEP LOGIC
  // =======================

  static int getTotalSteps(String worldId) =>
      _p.getInt(_keyTotal(worldId)) ?? 0;

  static Future<void> setTotalSteps(String worldId, int steps) async {
    await _p.setInt(_keyTotal(worldId), steps);
  }

  static int getLastRecordedToday(String worldId, String today) {
    final lastDate = _p.getString(_keyLastDate(worldId)) ?? '';

    if (lastDate != today) return 0;

    return _p.getInt(_keyTodayRecorded(worldId)) ?? 0;
  }

  static Future<void> updateTodayProgress(
      String worldId,
      int stepsFromHealth,
      String today,
      ) async {
    await _p.setInt(_keyTodayRecorded(worldId), stepsFromHealth);
    await _p.setString(_keyLastDate(worldId), today);
  }

  static Future<void> resetAll() async => await _p.clear();

  // =======================
  // 🎁 REWARD LOGIC
  // =======================

  /// Получить все открытые награды
  static List<String> getUnlockedRewards(String worldId) {
    return _p.getStringList(_keyRewards(worldId)) ?? [];
  }

  /// Проверка — открыта ли награда
  static bool isRewardUnlocked(String worldId, String rewardId) {
    final rewards = getUnlockedRewards(worldId);
    return rewards.contains(rewardId);
  }

  /// Открыть награду (если ещё не открыта)
  static Future<void> unlockReward(String worldId, String rewardId) async {
    final rewards = getUnlockedRewards(worldId);

    if (rewards.contains(rewardId)) return;

    rewards.add(rewardId);
    await _p.setStringList(_keyRewards(worldId), rewards);
  }

  /// Сброс наград только для одного мира
  static Future<void> resetRewards(String worldId) async {
    await _p.remove(_keyRewards(worldId));
  }

  // =======================
  // ⚠️ LEGACY
  // =======================

  static Future<void> updateWithTodaySteps(
      String worldId,
      int stepsTodayNew,
      String today,
      ) async {
    // больше не используется
  }
}