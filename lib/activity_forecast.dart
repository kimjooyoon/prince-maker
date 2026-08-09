import 'activity_catalog.dart';

const activityFatigueGuard = 8;

int recoveryDaysToClearFatigue(int fatigue, {int recoveryFatigueDelta = -2}) {
  final step = -recoveryFatigueDelta;
  if (fatigue < activityFatigueGuard || step <= 0) return 0;
  return (fatigue - (activityFatigueGuard - 1) + step - 1) ~/ step;
}

/// Shared forecast semantics: UI previews and the ECS growth system use this
/// exact fatigue/talent rule, so a preview cannot promise a different game.
int resolveActivityGrowth({
  required int delta,
  required int fatigue,
  required int bonus,
}) {
  final raw = delta + bonus;
  return (fatigue >= activityFatigueGuard ? (raw - 1).clamp(0, raw) : raw)
      .toInt();
}

class ActivityForecast {
  const ActivityForecast({
    required this.activityId,
    required this.stat,
    required this.rawGrowth,
    required this.growth,
    required this.growthPenalty,
    required this.coinsDelta,
    required this.fatigueDelta,
    required this.fatigueAfter,
    required this.recoveryDays,
    required this.nextCoins,
    required this.nextWeek,
    this.nextEventKey,
    this.nextMilestoneId,
    this.nextMilestoneKey,
  });

  final String activityId, stat;
  final int rawGrowth,
      growth,
      growthPenalty,
      coinsDelta,
      fatigueDelta,
      fatigueAfter,
      recoveryDays,
      nextCoins,
      nextWeek;
  final String? nextEventKey, nextMilestoneId, nextMilestoneKey;

  Map<String, Object?> toMap() => {
        'activityId': activityId,
        'stat': stat,
        'rawGrowth': rawGrowth,
        'growth': growth,
        'growthPenalty': growthPenalty,
        'coinsDelta': coinsDelta,
        'fatigueDelta': fatigueDelta,
        'fatigueAfter': fatigueAfter,
        'recoveryDays': recoveryDays,
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
  int recoveryFatigueDelta = -2,
  List<Map<String, dynamic>> events = const [],
  List<Map<String, dynamic>> milestones = const [],
}) {
  final bonus =
      activity.delta > 0 && focusStat == activity.stat ? focusBonus : 0;
  final rawGrowth = activity.delta + bonus,
      growth = resolveActivityGrowth(
          delta: activity.delta, fatigue: fatigue, bonus: bonus),
      growthPenalty =
          rawGrowth > 0 ? (rawGrowth - growth).clamp(0, rawGrowth).toInt() : 0,
      nextWeek = week + 1,
      fatigueAfter = (fatigue + activity.fatigue).clamp(0, 12).toInt(),
      recoveryDays = recoveryDaysToClearFatigue(fatigueAfter,
          recoveryFatigueDelta: recoveryFatigueDelta);
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
    rawGrowth: rawGrowth,
    growth: growth,
    growthPenalty: growthPenalty,
    coinsDelta: activity.coins,
    fatigueDelta: activity.fatigue,
    fatigueAfter: fatigueAfter,
    recoveryDays: recoveryDays,
    nextCoins: (coins + activity.coins).clamp(0, 999).toInt(),
    nextWeek: nextWeek,
    nextEventKey: nextEvent?['titleKey'] as String?,
    nextMilestoneId: nextMilestone?['id'] as String?,
    nextMilestoneKey: nextMilestone?['titleKey'] as String?,
  );
}
