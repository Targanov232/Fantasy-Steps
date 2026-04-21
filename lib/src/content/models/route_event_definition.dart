import 'reward_definition.dart';

class RouteEventDefinition {
  const RouteEventDefinition({
    required this.atKm,
    required this.text,
    this.reward,
  });

  final double atKm;
  final String text;
  final RewardDefinition? reward;
}
