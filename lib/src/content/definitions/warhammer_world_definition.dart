import 'dart:ui' show Offset;
import '../models/world_definition.dart';
import '../models/route_definition.dart';
import '../models/route_event_definition.dart';
import '../models/reward_definition.dart';
import '../models/flavor_text_definition.dart';

const List<Offset> warhammerPath = [
  Offset(0.22, 0.58), // Terra
  Offset(0.35, 0.52),
  Offset(0.48, 0.50),
  Offset(0.60, 0.45),
  Offset(0.72, 0.42), // север (хаос)
  Offset(0.78, 0.55),
  Offset(0.68, 0.72),
  Offset(0.50, 0.75),
  Offset(0.30, 0.70),
];

const List<FlavorTextDefinition> warhammerFlavorTexts = [];

const WorldDefinition warhammerWorldDefinition = WorldDefinition(flavorTexts: warhammerFlavorTexts,
  id: 'warhammer',
  name: 'Warhammer',
  mapAsset: 'assets/images/warhammer_map.png',
  path: warhammerPath,
  route: RouteDefinition(
    id: 'warhammer_main_route',
    name: 'Путь к Террам Хаоса',
    startLabel: 'Альтдорф',
    endLabel: 'Терры Хаоса',
    totalDistanceKm: 1200,
    events: [
      RouteEventDefinition(
        atKm: 300,
        text: 'Первый марш сквозь земли Империи завершен.',
      ),
      RouteEventDefinition(
        atKm: 700,
        text: 'Вы в северных пустошах. Опасность нарастает.',
        reward: RewardDefinition(
          id: 'warhammer_1',
          name: 'Молот',
          description: 'Символ силы Империи.',
          icon: 'warhammer_hammer.png',
        ),
      ),
      RouteEventDefinition(
        atKm: 1200,
        text: 'Вы достигли Терр Хаоса.',
      ),
    ],
  ),
);
