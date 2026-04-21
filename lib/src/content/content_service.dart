import '../domain/reward.dart';
import '../domain/world_service.dart';
import 'models/world_definition.dart';
import 'world_registry.dart';

class ContentService {
  ContentService._();
  static final ContentService instance = ContentService._();

  WorldDefinition? getById(String worldId) {
    return WorldRegistry.getWorld(worldId);
  }

  WorldDefinition? getActiveWorldDefinition() {
    return getById(WorldService.instance.activeWorldId);
  }

  String worldName(String worldId) {
    final world = getById(worldId);
    return world?.name ?? worldId;
  }

  String routeName(String worldId) {
    final world = getById(worldId);
    return world?.route.routeLabel ?? worldId;
  }

  String? mapAsset(String worldId) {
    final world = getById(worldId);
    return world?.mapAsset;
  }

  List<Reward> rewardsForWorld(String worldId) {
    final world = getById(worldId);
    if (world == null) return const [];

    return world.route.events
        .where((e) => e.reward != null)
        .map((e) => e.reward!.toDomainReward())
        .toList(growable: false);
  }
}
