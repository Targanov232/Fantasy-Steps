import 'package:flutter/material.dart';
import '../data/step_storage.dart';
import '../domain/route_config.dart';
import '../domain/world_service.dart';
import '../theme/app_theme.dart';
import '../widgets/world_card.dart';
import 'home_screen.dart';

class WorldSelectionScreen extends StatefulWidget {
  const WorldSelectionScreen({super.key});

  @override
  State<WorldSelectionScreen> createState() =>
      WorldSelectionScreenState();
}

class WorldSelectionScreenState extends State<WorldSelectionScreen> {
  bool _showHome = false;

  /// 👉 мир, который мы ПРОСМАТРИВАЕМ
  WorldType _viewingWorld = WorldService.instance.activeWorld;

  /// =========================
  /// 🔥 УПРАВЛЕНИЕ ИЗ НАВИГАТОРА
  /// =========================

  /// 👉 сброс в список миров
  void resetToWorldList() {
    if (!mounted) return;
    setState(() {
      _showHome = false;
    });
  }

  /// 👉 обработка кнопки "назад"
  bool handleBack() {
    if (_showHome) {
      setState(() {
        _showHome = false;
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final activeWorld = WorldService.instance.activeWorld;

    final stepsLotr = StepStorage.getTotalSteps(WorldType.lotr.name);
    final distLotr = stepsToKm(stepsLotr);

    final stepsWarhammer = StepStorage.getTotalSteps(WorldType.warhammer.name);
    final distWarhammer = stepsToKm(stepsWarhammer);

    return _showHome
        ? HomeScreen(
            viewingWorld: _viewingWorld,
            onExitWorld: resetToWorldList,
          )
        : Scaffold(
            backgroundColor: AppColors.parchment,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Fantasy Step',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Выбери мир для путешествия',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Отметь его галочкой, чтобы шаги сохранялись в нём',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  /// LOTR
                  WorldCard(
                    title: 'Властелин Колец',
                    routeText: 'Шир → Роковая Гора',
                    image: 'assets/images/world_lotr.jpg',
                    progress: (distLotr / 2900).clamp(0.0, 1.0),
                    isActive: activeWorld == WorldType.lotr,
                    onSelect: () {
                      setState(() {
                        WorldService.instance.setActiveWorld(WorldType.lotr);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Цель установлена: Властелин Колец'),
                        ),
                      );
                    },
                    onTap: () {
                      setState(() {
                        _viewingWorld = WorldType.lotr;
                        _showHome = true;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  /// WARHAMMER
                  WorldCard(
                    title: 'Warhammer',
                    routeText: 'Альтдорф → Терры Хаоса',
                    image: 'assets/images/world_warhammer.jpg',
                    progress: (distWarhammer / 1200).clamp(0.0, 1.0),
                    isActive: activeWorld == WorldType.warhammer,
                    onSelect: () {
                      setState(() {
                        WorldService.instance.setActiveWorld(WorldType.warhammer);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Цель установлена: Warhammer'),
                        ),
                      );
                    },
                    onTap: () {
                      setState(() {
                        _viewingWorld = WorldType.warhammer;
                        _showHome = true;
                      });
                    },
                  ),
                ],
              ),
            ),
          );
  }
}