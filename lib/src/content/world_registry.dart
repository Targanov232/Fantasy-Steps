import 'models/world_definition.dart';
import 'definitions/lotr_world_definition.dart';
import 'definitions/warhammer_world_definition.dart';

class WorldRegistry {
  WorldRegistry._();

  static final Map<String, WorldDefinition> _worlds = {
    lotrWorldDefinition.id: lotrWorldDefinition,
    warhammerWorldDefinition.id: warhammerWorldDefinition,
  };

  static WorldDefinition? getWorld(String worldId) => _worlds[worldId];

  static List<WorldDefinition> get allWorlds =>
      _worlds.values.toList(growable: false);
}
