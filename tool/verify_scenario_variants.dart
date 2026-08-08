import 'dart:convert';
import 'dart:io';

import 'package:prince_maker/game_core.dart';

Never fail(String message) {
  stderr.writeln('SCENARIO_VARIANTS_FAIL: $message');
  exit(1);
}

bool available(Map<String, dynamic> choice, GameSession session) {
  final stats = session.world.stats[0]!.values;
  final progress = session.world.progress[0]!;
  return (choice['requiresStat'] == null ||
          (stats[choice['requiresStat']] ?? 0) >=
              (choice['requiresMin'] as int? ?? 0)) &&
      (choice['requiresBondId'] == null ||
          (progress.bonds[choice['requiresBondId']] ?? 0) >=
              (choice['requiresBondMin'] as int? ?? 0)) &&
      (choice['requiresFlag'] == null ||
          progress.flags[choice['requiresFlag']] == true);
}

void chooseEvent(GameSession session, Map<String, dynamic> choice) {
  session.chooseEvent(StoryChoiceMade(
    choice['stat'],
    choice['delta'],
    choice['coins'],
    choice['label'],
    bondId: choice['bondId'],
    bondDelta: choice['bondDelta'],
    rivalId: choice['rivalId'],
    rivalDelta: choice['rivalDelta'] ?? 0,
    requiresStat: choice['requiresStat'],
    requiresMin: choice['requiresMin'] ?? 0,
    requiresBondId: choice['requiresBondId'],
    requiresBondMin: choice['requiresBondMin'] ?? 0,
    requiresFlag: choice['requiresFlag'],
    setsFlag: choice['setsFlag'],
    line: choice['line'] ?? '',
  ));
}

String replaySignature(GameSession session, Map<String, dynamic> ending) {
  final progress = session.world.progress[0]!;
  final eventTrace = progress.trace
      .where((entry) => entry.startsWith('event:'))
      .join('||');
  final milestones = progress.milestones.entries
      .map((entry) => '${entry.key}:${entry.value}')
      .join(',');
  final flags = progress.flags.entries
      .map((entry) => '${entry.key}:${entry.value}')
      .join(',');
  return [
    ending['id'],
    (ending['companionRouteIds'] as List? ?? const []).join('+'),
    session.world.stats[0]!.values,
    progress.bonds,
    milestones,
    flags,
    eventTrace,
  ].join('|');
}

String runBranchVector(Map<String, dynamic> source, List<int> branchWeeks,
    int mask) {
  final story = JsonStoryAdapter(source);
  final session = GameSession(story, MemorySaveAdapter());
  var branchIndex = 0;
  final eventsByWeek = <int, Map<String, dynamic>>{
    for (final event in story.events) event['week'] as int: event,
  };
  while (session.world.progress[0]!.week < story.endingWeek) {
    session.choose(const ActivityChosen('지혜', 1, 0, 0, label: 'case-explorer'));
    final week = session.world.progress[0]!.week;
    final event = eventsByWeek[week];
    if (event == null) continue;
    final choices = (event['choices'] as List).cast<Map<String, dynamic>>();
    final usable = choices.where((choice) => available(choice, session)).toList();
    if (branchWeeks.contains(week)) {
      if (usable.length != 2 || choices.length != 2)
        fail('branch week $week is not an unconditional two-choice event');
      final selected = choices[(mask >> branchIndex) & 1];
      if (!available(selected, session))
        fail('branch week $week became unavailable for mask $mask');
      branchIndex++;
      chooseEvent(session, selected);
    } else {
      if (usable.isEmpty) fail('event week $week has no available choice');
      chooseEvent(session, usable.first);
    }
  }
  if (branchIndex != branchWeeks.length)
    fail('branch vector consumed $branchIndex/${branchWeeks.length} axes');
  final progress = session.world.progress[0]!;
  final ending = resolveEnding(story, session.world.stats[0]!.values,
      bonds: progress.bonds, milestones: progress.milestones);
  return replaySignature(session, ending);
}

void main() {
  final source = jsonDecode(File('story/story.json').readAsStringSync())
      as Map<String, dynamic>;
  final budget = (source['scenarioVariantBudget'] as Map?)
      ?.cast<String, dynamic>();
  if (budget == null || budget['schema'] != 'lumen-scenario-cases-v1')
    fail('missing scenario variant budget');
  final branchWeeks = (budget['branchWeeks'] as List).cast<int>();
  if (branchWeeks.length < 11 || branchWeeks.toSet().length != branchWeeks.length)
    fail('at least eleven unique branch weeks are required');
  final eventByWeek = <int, Map<String, dynamic>>{
    for (final event in (source['events'] as List).cast<Map<String, dynamic>>())
      event['week'] as int: event,
  };
  for (final week in branchWeeks) {
    final event = eventByWeek[week];
    if (event == null) fail('branch week $week has no authored event');
    final choices = (event['choices'] as List).cast<Map<String, dynamic>>();
    if (choices.length != 2 ||
        choices.any((choice) => choice['requiresStat'] != null ||
            choice['requiresBondId'] != null ||
            choice['requiresFlag'] != null)) {
      fail('branch week $week must expose two unconditional authored choices');
    }
  }
  final branchVectors = 1 << branchWeeks.length;
  final expectedBranchVectors = budget['authoredBranchVectors'];
  if (expectedBranchVectors != branchVectors)
    fail('branch vector formula drift: expected $branchVectors, found $expectedBranchVectors');
  final activities = (source['activities'] as List).length;
  final personalities = (source['personalities'] as List).length;
  final legacyContexts = (source['legacyProfiles'] as List).length + 1;
  final routeInputs = branchVectors * activities * personalities * legacyContexts;
  if (budget['routeInputCases'] != routeInputs ||
      (budget['minimumCases'] as int) < 2000)
    fail('scenario case budget is below the 2,000-case contract');

  final signatures = <String>{};
  for (var mask = 0; mask < branchVectors; mask++) {
    signatures.add(runBranchVector(source, branchWeeks, mask));
  }
  final reachable = signatures.length;
  if (reachable < (budget['minimumCases'] as int))
    fail('only $reachable distinct deterministic scenario signatures were reached');
  if (budget['verifiedReachableCases'] != reachable)
    fail('verifiedReachableCases drift: expected $reachable, found ${budget['verifiedReachableCases']}');
  stdout.writeln(
      'SCENARIO_VARIANTS_OK: cases=$reachable minimum=${budget['minimumCases']} branchVectors=$branchVectors routeInputs=$routeInputs branchWeeks=${branchWeeks.join(',')}');
}
