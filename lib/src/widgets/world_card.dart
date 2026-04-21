import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WorldCard extends StatelessWidget {
  final String title;
  final String routeText;
  final double progress;
  final String image;
  final VoidCallback onTap;
  final VoidCallback onSelect; // Колбэк для выбора активного мира
  final bool isActive;

  const WorldCard({
    super.key,
    required this.title,
    required this.routeText,
    required this.progress,
    required this.image,
    required this.onTap,
    required this.onSelect, // Добавили в обязательные
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            /// 1. Основная область нажатия (вся карточка)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap, // Просто вход в мир
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(image, fit: BoxFit.cover),
                      ),
                      Positioned.fill(
                        child: Container(color: Colors.black.withOpacity(0.35)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// 🟢 ИНДИКАТОР ВЫБОРА (ГАЛОЧКА)
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: onSelect, // Смена активного мира для шагов
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    // Если выбран — заливаем зеленым, если нет — полупрозрачный черный
                    color: isActive ? AppColors.green : Colors.black26,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive ? Colors.white : Colors.white54,
                      width: 2,
                    ),
                    boxShadow: [
                      if (isActive)
                        BoxShadow(
                          color: AppColors.green.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: Icon(
                    isActive ? Icons.check : null, // Если не выбран — иконки нет (пустой круг)
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            /// 3. Текстовый контент (игнорирует нажатия, чтобы работал InkWell снизу)
            IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      routeText,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const Spacer(),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}