import 'dart:ui' show Offset;
import 'route_definition.dart';
import 'flavor_text_definition.dart';

class WorldDefinition {
  const WorldDefinition({
    required this.id,
    required this.name,
    required this.mapAsset,
    required this.path,
    required this.route,
    this.flavorTexts = const [],
  });

  final String id;
  final String name;
  final String mapAsset;

  /// Normalized path points (0..1)
  final List<Offset> path;

  final RouteDefinition route;

  /// Атмосферные цитаты (привязанные к прогрессу)
  final List<FlavorTextDefinition> flavorTexts;
}