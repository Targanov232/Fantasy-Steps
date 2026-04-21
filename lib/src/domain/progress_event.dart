class ProgressEvent {
  const ProgressEvent({
    required this.type,
    required this.worldId,
    this.rewardId,
    this.metadata,
  });

  final String type;
  final String worldId;
  final String? rewardId;
  final Map<String, Object?>? metadata;

  static const String rewardUnlocked = 'reward_unlocked';
  static const String milestoneReached = 'milestone_reached';
  static const String progressUpdated = 'progress_updated';
}
