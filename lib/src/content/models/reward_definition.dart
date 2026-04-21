import '../../domain/reward.dart';

class RewardDefinition {
  const RewardDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final String icon;

  Reward toDomainReward() {
    return Reward(
      id: id,
      name: name,
      description: description,
      icon: icon,
    );
  }
}
