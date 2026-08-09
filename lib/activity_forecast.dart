import 'activity_catalog.dart';

/// Shared forecast semantics: UI previews and the ECS growth system use this
/// exact fatigue/talent rule, so a preview cannot promise a different game.
int resolveActivityGrowth({
  required int delta,
  required int fatigue,
  required int bonus,
}) {
  final raw = delta + bonus;
  return (fatigue >= 8 ? (raw - 1).clamp(0, raw) : raw).toInt();
}

class ActivityForecast {
  const ActivityForecast({
    required this.activityId,
    required this.stat,
    required this.growth,
    required this.coinsDelta,
    required this.fatigueDelta,
    required this.fatigueAfter,
    required this.nextCoins,
    required this.nextWeek,
      this.nextEventKey,
      this.nextMilestoneId,
      this.nextMilestoneKey,
  });

  final String activityId, stat;
  final int growth, coinsDelta, fatigueDelta, fatigueAfter, nextCoins, nextWeek;
  final String? nextEventKey,
      nextMilestoneId,
      nextMilestoneKey;

  Map<String, Object?> toMap() => {
        'activityId': activityId,
        'stat': stat,
        'growth': growth,
        'coinsDelta': coinsDelta,
        'fatigueDelta': fatigueDelta,
        'fatigueAfter': fatigueAfter,
        'nextCoins': nextCoins,
        'nextWeek': nextWeek,
        'nextEventKey': nextEventKey,
        'nextMilestoneId': nextMilestoneId,
        'nextMilestoneKey': nextMilestoneKey,
      };
}

ActivityForecast forecastActivity(
  Activity activity, {
  required int week,
  required int fatigue,
  required int coins,
  String? focusStat,
  int focusBonus = 0,
  List<Map<String, dynamic>> events = const [],
  List<Map<String, dynamic>> milestones = const [],
}) {
  final bonus =
      activity.delta > 0 && focusStat == activity.stat ? focusBonus : 0;
  final nextWeek = week + 1;
  final nextEvent =
      events.where((event) => event['week'] == nextWeek).firstOrNull;
  final nextMilestone = nextEvent == null
      ? milestones
          .where((milestone) => milestone['week'] == nextWeek)
          .firstOrNull
      : null;
  return ActivityForecast(
    activityId: activity.id,
    stat: activity.stat,
    growth: resolveActivityGrowth(
        delta: activity.delta, fatigue: fatigue, bonus: bonus),
    coinsDelta: activity.coins,
    fatigueDelta: activity.fatigue,
    fatigueAfter: (fatigue + activity.fatigue).clamp(0, 12).toInt(),
    nextCoins: (coins + activity.coins).clamp(0, 999).toInt(),
    nextWeek: nextWeek,
    nextEventKey: nextEvent?['titleKey'] as String?,
    nextMilestoneId: nextMilestone?['id'] as String?,
    nextMilestoneKey: nextMilestone?['titleKey'] as String?,
  );
}
