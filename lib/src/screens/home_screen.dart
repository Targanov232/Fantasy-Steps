import 'package:flutter/material.dart';
import '../domain/route_config.dart';
import '../domain/step_service.dart';
import '../domain/world_service.dart';
import '../data/step_storage.dart';
import '../widgets/map_widget.dart';
import '../data/cloud_storage.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onExitWorld;
  final WorldType viewingWorld;

  const HomeScreen({
    super.key,
    required this.onExitWorld,
    required this.viewingWorld,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _totalSteps = 0;
  bool _loading = false;
  String? _error;

  bool _healthAvailable = false;
  bool _healthConnected = false;
  bool _checkingHealth = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _autoSync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _autoSync() async {
    if (!mounted) return;

    setState(() => _loading = true);

    try {
      _loadFromStorage();
      await _initialSync();

      final isAvailable = await StepService.instance.isHealthAvailable();
      if (isAvailable) {
        final hasPermission = await StepService.instance.requestPermission();
        if (hasPermission) {
          await _refreshSteps();
        }
      }
    } catch (e) {
      debugPrint("AutoSync Error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _loadFromStorage() {
    final viewId = widget.viewingWorld.id;
    setState(() {
      _totalSteps = StepStorage.getTotalSteps(viewId);
    });
  }

  Future<void> _initialSync() async {
    final viewId = widget.viewingWorld.id;

    try {
      final cloudSteps = await CloudStorage.loadProgress(viewId);

      if (cloudSteps != null &&
          cloudSteps > StepStorage.getTotalSteps(viewId)) {
        await StepStorage.setTotalSteps(viewId, cloudSteps);
      }

      await _checkHealthStatus();

      if (_healthConnected) {
        await StepService.instance.refreshSteps();
      }
    } catch (e) {
      debugPrint("Initial sync error: $e");
    } finally {
      if (mounted) _loadFromStorage();
    }
  }

  Future<void> _checkHealthStatus() async {
    setState(() => _checkingHealth = true);

    final available = await StepService.instance.isHealthAvailable();
    bool connected = false;

    if (available) {
      connected = await StepService.instance.hasHealthPermission();
    }

    if (!mounted) return;

    setState(() {
      _healthAvailable = available;
      _healthConnected = connected;
      _checkingHealth = false;
    });
  }

  Future<void> _refreshSteps() async {
    if (!_healthAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Health Connect не найден')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await StepService.instance.refreshSteps();

      final activeId = WorldService.instance.activeWorldId;
      final activeSteps = StepStorage.getTotalSteps(activeId);

      if (result.isSuccess) {
        await CloudStorage.saveProgress(activeId, activeSteps);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Шаги синхронизированы')),
        );
      } else {
        _error = result.error;
      }
    } catch (e) {
      _error = "Ошибка: $e";
    } finally {
      if (mounted) {
        _loadFromStorage();
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final distanceKm = stepsToKm(_totalSteps);

    final String routeName = widget.viewingWorld == WorldType.lotr
        ? "Шир → Роковая Гора"
        : "Альтдорф → Терры Хаоса";

    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          routeName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// СТАТИСТИКА
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: "Суммарные шаги",
                    value: _totalSteps.toString(),
                    icon: Icons.directions_walk,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: "Пройдено км",
                    value: distanceKm.toStringAsFixed(1),
                    icon: Icons.straighten,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            /// СТАТУС HEALTH
            if (_checkingHealth) ...[
              const _StatusBox(
                color: Colors.blueGrey,
                text: "🚶 Считаем ваши шаги...",
              ),
              const SizedBox(height: 16),
            ] else if (!_healthConnected) ...[
              _StatusBox(
                color: !_healthAvailable ? Colors.red : Colors.orange,
                text: !_healthAvailable
                    ? "Health Connect не найден"
                    : "Нет доступа к шагам\nВыдайте разрешение",
              ),
              const SizedBox(height: 16),
            ],

            /// КНОПКА
            FilledButton.icon(
              onPressed: _loading ? null : _refreshSteps,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.textPrimary,
              ),
              icon: _loading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.refresh),
              label: Text(_loading ? "Обновление..." : "Обновить шаги"),
            ),

            const SizedBox(height: 30),

            /// КАРТА
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: MapWidget(
                worldId: widget.viewingWorld.id,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBox extends StatelessWidget {
  const _StatusBox({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}