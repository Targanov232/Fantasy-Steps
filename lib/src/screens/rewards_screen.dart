import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../content/content_service.dart';
import '../domain/world_service.dart';
import '../domain/progress_engine.dart';
import '../domain/progress_event.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  StreamSubscription<ProgressEvent>? _progressEventsSub;

  @override
  void initState() {
    super.initState();
    _progressEventsSub = ProgressEngine.instance.events.listen((event) {
      if (!mounted) return;
      if (event.type == ProgressEvent.progressUpdated) return;

      if (event.type == ProgressEvent.rewardUnlocked) {
        final rewardName = event.metadata?['rewardName']?.toString() ?? event.rewardId ?? 'Награда';
        final worldName = ContentService.instance.worldName(event.worldId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎁 Открыто: $rewardName ($worldName)'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _progressEventsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Награды',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildWorldTile(context, 'Властелин колец', WorldType.lotr),
          const SizedBox(height: 12),
          _buildWorldTile(context, 'Warhammer', WorldType.warhammer),
        ],
      ),
    );
  }

  Widget _buildWorldTile(BuildContext context, String title, WorldType world) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RewardsDetailScreen(world: world, title: title),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.public, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

/// =======================
/// 🎁 DETAIL SCREEN
/// =======================

class RewardsDetailScreen extends StatelessWidget {
  final WorldType world;
  final String title;

  const RewardsDetailScreen({
    super.key,
    required this.world,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final rewards = _getRewardsForWorld(world.name);

    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rewards.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final reward = rewards[index];

          // ПОКА заглушка: все закрыты
          final bool unlocked = false;

          return _buildRewardItem(reward, unlocked);
        },
      ),
    );
  }

  Widget _buildRewardItem(Map<String, String> reward, bool unlocked) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.card_giftcard,
            size: 40,
            color: unlocked ? AppColors.gold : Colors.white24,
          ),
          if (!unlocked)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
        ],
      ),
    );
  }

  /// =======================
  /// CONTENT DATA
  /// =======================
  List<Map<String, String>> _getRewardsForWorld(String worldId) {
    final rewards = ContentService.instance.rewardsForWorld(worldId);
    return rewards
        .map((r) => {'id': r.id, 'name': r.name})
        .toList(growable: false);
  }
}