import 'dart:ui' show Offset;
import '../models/world_definition.dart';
import '../models/route_definition.dart';
import '../models/route_event_definition.dart';
import '../models/reward_definition.dart';
import '../models/flavor_text_definition.dart';

const List<Offset> lotrPath = [
  Offset(0.03, 0.10),
  Offset(0.12, 0.11),
  Offset(0.21, 0.10),
  Offset(0.31, 0.09),
  Offset(0.40, 0.10),
  Offset(0.47, 0.11),
  Offset(0.50, 0.18),
  Offset(0.48, 0.27),
  Offset(0.50, 0.34),
  Offset(0.56, 0.41),
  Offset(0.61, 0.49),
  Offset(0.62, 0.58),
  Offset(0.62, 0.66),
  Offset(0.71, 0.66),
  Offset(0.80, 0.69),
  Offset(0.84, 0.77),
  Offset(0.84, 0.86),
];

const List<FlavorTextDefinition> lotrFlavorTexts = [];

const WorldDefinition lotrWorldDefinition = WorldDefinition(flavorTexts: lotrFlavorTexts,
  id: 'lotr',
  name: 'Властелин Колец',
  mapAsset: 'assets/images/middle_earth_map.png',
  path: lotrPath,
  route: RouteDefinition(
    id: 'lotr_main_route',
    name: 'Путь к Роковой Горе',
    startLabel: 'Шир',
    endLabel: 'Роковая Гора',
    totalDistanceKm: 2500,
    events: [
      RouteEventDefinition(
        atKm: 50,
        text: 'Вы покидаете Шир. Дорога уходит вдаль...',
      ),
      RouteEventDefinition(
        atKm: 450,
        text: 'Вы достигаете Ривенделла. Здесь можно отдохнуть.',
        reward: RewardDefinition(
          id: 'lembas',
          name: 'Лембас',
          description: 'Эльфийский хлеб. Один кусок насыщает на целый день.',
          icon: 'lembas.png',
        ),
      ),
      RouteEventDefinition(
        atKm: 970,
        text: 'Лотлориэн. Золотой лес встречает вас тишиной.',
        reward: RewardDefinition(
          id: 'phial',
          name: 'Фиал Галадриэли',
          description: 'Свет в темноте. Дар, который не гаснет.',
          icon: 'phial.png',
        ),
      ),
      RouteEventDefinition(
        atKm: 1550,
        text: 'Минас-Тирит. Белый город стоит величественно.',
        reward: RewardDefinition(
          id: 'white_tree',
          name: 'Лист Белого Древа',
          description: 'Символ надежды Гондора.',
          icon: 'white_tree.png',
        ),
      ),
      RouteEventDefinition(
        atKm: 1970,
        text: 'Минас-Моргул. Воздух здесь тяжёл и холоден.',
      ),
      RouteEventDefinition(
        atKm: 2500,
        text: 'Вы у подножия Роковой горы. Последний подъём.',
        reward: RewardDefinition(
          id: 'doom_ash',
          name: 'Пепел Роковой горы',
          description: 'Конец пути. Но не конец истории.',
          icon: 'doom_ash.png',
        ),
      ),
    ],
  ),
);
