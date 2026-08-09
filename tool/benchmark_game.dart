import 'dart:convert';
import 'dart:io';
import 'package:prince_maker/jsonl.dart';
import 'package:prince_maker/game_core.dart';
import 'package:prince_maker/activity_catalog.dart';
import 'package:prince_maker/activity_forecast.dart';

class CampaignMetrics {
  CampaignMetrics(
      this.checksum,
      this.forecastChecksum,
      this.companionSceneChecksum,
      this.companionScenes,
      this.companionChoiceModes,
      this.endings,
      this.signatures,
      this.locations,
      this.lineageEndings,
      this.lineageSignatures,
      this.lineageCompanions);
  final int checksum, forecastChecksum, companionSceneChecksum;
  final Set<String> companionScenes;
  final Set<int> companionChoiceModes;
  final Set<String> endings, signatures, locations;
  final Map<String, Set<String>> lineageEndings,
      lineageSignatures,
      lineageCompanions;
}

CampaignMetrics runCampaigns(Map<String, dynamic> source, int campaigns) {
  var checksum = 0;
  var forecastChecksum = 0;
  var companionSceneChecksum = 0;
  final companionScenes = <String>{};
  final companionChoiceModes = <int>{};
  final endings = <String>{}, signatures = <String>{}, locations = <String>{};
  final lineageEndings = <String, Set<String>>{},
      lineageSignatures = <String, Set<String>>{},
      lineageCompanions = <String, Set<String>>{};
  final story = JsonStoryAdapter(source);
  final eventsByWeek = <int, Map<String, dynamic>>{
    for (final event in story.events) event['week'] as int: event,
  };
  final legacyIds = story.legacyProfiles.map((p) => '${p['id']}').toList();
  final activities = activitiesFromStory(source),
      personality = story.personalities.firstOrNull;
  for (var i = 0; i < campaigns; i++) {
    final legacyId = i.isEven && legacyIds.isNotEmpty
        ? legacyIds[i % legacyIds.length]
        : null;
    final session = GameSession(story, MemorySaveAdapter(),
        legacyUnlocked: i.isEven, legacyId: legacyId, autoPersist: false);
    final legacyProfile = legacyId == null
        ? null
        : story.legacyProfiles.firstWhere((p) => p['id'] == legacyId);
    while (session.world.progress[0]!.week < story.endingWeek) {
      final p = session.world.progress[0]!;
      for (final activity in activities) {
        final forecast = forecastActivity(activity,
            week: p.week,
            fatigue: p.fatigue,
            coins: p.coins,
            focusStat: personality?['focusStat'] as String?,
            focusBonus: personality?['focusBonus'] as int? ?? 0,
            events: story.events,
            milestones: story.milestones);
        forecastChecksum += forecast.growth * 31 +
            forecast.nextCoins * 7 +
            forecast.fatigueAfter * 5 +
            forecast.nextWeek;
      }
      final week = session.world.progress[0]!.week;
      final stat = legacyProfile?['stat'] as String? ??
          switch ((i + week) % 3) { 0 => '지혜', 1 => '공감', _ => '용기' };
      session.choose(ActivityChosen(stat, 2, 1, 1, label: 'benchmark:$stat'));
      final event = eventsByWeek[session.world.progress[0]!.week];
      if (event != null) {
        final choices = (event['choices'] as List).cast<Map<String, dynamic>>();
        final available = choices
            .where((c) =>
                (c['requiresStat'] == null ||
                    (session.world.stats[0]!.values[c['requiresStat']] ?? 0) >=
                        (c['requiresMin'] as int? ?? 0)) &&
                (c['requiresBondId'] == null ||
                    (session.world.progress[0]!.bonds[c['requiresBondId']] ??
                            0) >=
                        (c['requiresBondMin'] as int? ?? 0)) &&
                (c['requiresFlag'] == null ||
                    session.world.progress[0]!.flags[c['requiresFlag']] ==
                        true))
            .toList();
        final choice = available[(i + week) % available.length];
        final targetCompanion = legacyProfile?['companionId'] as String?;
        final legacyChoice = available.where((candidate) {
          final hasLegacyBonus =
              (candidate['legacyBonuses'] as Map?)?.containsKey(legacyId) ==
                  true;
          return hasLegacyBonus;
        }).toList();
        final companionChoice = available
            .where((candidate) => candidate['bondId'] == targetCompanion)
            .toList();
        final selected = legacyChoice.isNotEmpty
            ? legacyChoice.first
            : companionChoice.isNotEmpty
                ? companionChoice.first
                : choice;
        session.chooseEvent(StoryChoiceMade(
          selected['stat'],
          selected['delta'],
          selected['coins'],
          selected['label'],
          bondId: selected['bondId'],
          bondDelta: selected['bondDelta'],
          rivalId: selected['rivalId'],
          rivalDelta: selected['rivalDelta'] ?? 0,
          requiresStat: selected['requiresStat'],
          requiresMin: selected['requiresMin'] ?? 0,
          requiresBondId: selected['requiresBondId'],
          requiresBondMin: selected['requiresBondMin'] ?? 0,
          requiresFlag: selected['requiresFlag'],
          setsFlag: selected['setsFlag'],
          legacyBonuses:
              (selected['legacyBonuses'] as Map?)?.cast<String, dynamic>(),
          legacyId: session.legacyId,
          line: selected['line'] ?? '',
        ));
      }
    }
    final p = session.world.progress[0]!;
    final currentChapter = ((p.week + 2) ~/ 3).clamp(1, 16);
    final availableCompanionScenes = resolveCompanionScenes(
            story, p.bonds, p.flags,
            currentChapter: currentChapter)
        .where((scene) => scene['available'] == true)
        .toList();
    for (var sceneIndex = 0;
        sceneIndex < availableCompanionScenes.length;
        sceneIndex++) {
      final scene = availableCompanionScenes[sceneIndex];
      final sceneId = '${scene['id']}';
      final choiceIndex = (i + sceneIndex + currentChapter) % 2,
          before = session.world.progress[0]!.trace.length;
      session.recordCompanionScene(sceneId, choiceIndex: choiceIndex);
      final choiceTrace = session.world.progress[0]!.trace
          .skip(before)
          .where((entry) => entry.startsWith('companion-choice:'))
          .join('|');
      companionChoiceModes.add(choiceIndex);
      companionScenes.add(sceneId);
      companionSceneChecksum = companionSceneChecksum * 31 +
          sceneId.codeUnits.fold<int>(0, (sum, code) => sum * 31 + code) +
          choiceIndex * 17 +
          choiceTrace.codeUnits.fold<int>(0, (sum, code) => sum * 31 + code) +
          session.world.progress[0]!.trace.length;
    }
    final completed = session.world.progress[0]!;
    final ending = resolveEnding(story, session.world.stats[0]!.values,
        bonds: completed.bonds,
        milestones: completed.milestones,
        flags: completed.flags);
    endings.add('${ending['id']}');
    locations.addAll(p.flags.keys.where((key) => key.startsWith('place:')));
    final companionChoiceTrace = completed.trace
        .where((entry) => entry.startsWith('companion-choice:'))
        .join(';');
    final signature =
            '${ending['routeId']}|${session.world.stats[0]!.values}|${completed.bonds}|${completed.milestones.values.where((v) => v).length}|${completed.flags}|$companionChoiceTrace',
        lineage = session.legacyId ?? 'none';
    signatures.add(signature);
    lineageEndings
        .putIfAbsent(lineage, () => <String>{})
        .add('${ending['id']}');
    lineageSignatures.putIfAbsent(lineage, () => <String>{}).add(signature);
    lineageCompanions.putIfAbsent(lineage, () => <String>{}).addAll(
        ((ending['epilogues'] as List?) ?? const [])
            .map((route) => '${(route as Map)['id']}'));
    checksum += completed.week +
        session.world.stats[0]!.values.values.reduce((a, b) => a + b) +
        completed.bonds.values.reduce((a, b) => a + b) +
        completed.trace.length;
  }
  return CampaignMetrics(
      checksum,
      forecastChecksum,
      companionSceneChecksum,
      companionScenes,
      companionChoiceModes,
      endings,
      signatures,
      locations,
      lineageEndings,
      lineageSignatures,
      lineageCompanions);
}

void main() {
  const campaigns = 5000;
  final source = decodeJsonl(File('story/story.jsonl').readAsStringSync());
  final story = JsonStoryAdapter(source);
  final watch = Stopwatch()..start();
  final first = runCampaigns(source, campaigns);
  watch.stop();
  final replay = runCampaigns(source, campaigns);
  final millis = watch.elapsedMicroseconds / 1000;
  final transitions = campaigns *
      ((source['endingWeek'] as int) -
          1 +
          (source['events'] as List).length +
          (source['companionScenes'] as List? ?? const []).length);
  final profileIds = story.legacyProfiles.map((p) => '${p['id']}').toSet(),
      lineageEvidence = profileIds.every(
          (id) => (first.lineageSignatures[id] ?? const <String>{}).isNotEmpty),
      lineageEndingEvidence = story.legacyProfiles.every((profile) {
        final id = '${profile['id']}',
            targets = (profile['endingIds'] as List? ?? const [])
                .map((ending) => '$ending')
                .toSet();
        return (first.lineageEndings[id] ?? const <String>{})
            .any(targets.contains);
      }),
      lineageCompanionEvidence = story.legacyProfiles.every((profile) {
        final id = '${profile['id']}', target = '${profile['companionId']}';
        return (first.lineageCompanions[id] ?? const <String>{})
            .contains(target);
      }),
      lineageSummary = profileIds.map((id) {
        final target = story.legacyProfiles
            .firstWhere((profile) => profile['id'] == id)['companionId'];
        final endingIds =
            (first.lineageEndings[id] ?? const <String>{}).toList()..sort();
        final companions =
            (first.lineageCompanions[id] ?? const <String>{}).toList()..sort();
        return '$id:${endingIds.join('+')}|target:$target|routes:${companions.join('+')}/${first.lineageSignatures[id]?.length ?? 0}sig';
      }).join(',');
  final approved = millis <= 24000 &&
      first.checksum > campaigns &&
      replay.checksum == first.checksum &&
      replay.forecastChecksum == first.forecastChecksum &&
      replay.companionSceneChecksum == first.companionSceneChecksum &&
      replay.companionChoiceModes.length == first.companionChoiceModes.length &&
      first.companionChoiceModes.containsAll({0, 1}) &&
      replay.companionScenes.length == first.companionScenes.length &&
      replay.endings.length == first.endings.length &&
      replay.signatures.length == first.signatures.length &&
      replay.locations.length == first.locations.length &&
      first.locations.length >= 4 &&
      first.signatures.length >= 3 &&
      first.companionScenes.length >= 3 &&
      lineageEvidence &&
      lineageEndingEvidence &&
      lineageCompanionEvidence &&
      replay.lineageSignatures.toString() ==
          first.lineageSignatures.toString() &&
      replay.lineageCompanions.toString() == first.lineageCompanions.toString();
  final report = {
    'schema': 'lumen-campaign-benchmark-v1',
    'decision': approved ? 'approve' : 'reject',
    'campaigns': campaigns,
    'transitions': transitions,
    'elapsedMillis': double.parse(millis.toStringAsFixed(1)),
    'endings': first.endings.length,
    'signatures': first.signatures.length,
    'locations': first.locations.length,
    'checksum': first.checksum,
    'replayChecksum': replay.checksum,
    'forecastChecksum': first.forecastChecksum,
    'replayForecastChecksum': replay.forecastChecksum,
    'companionScenes': first.companionScenes.length,
    'companionSceneChecksum': first.companionSceneChecksum,
    'replayCompanionSceneChecksum': replay.companionSceneChecksum,
    'companionSceneChoiceModes': first.companionChoiceModes.toList()..sort(),
    'companionSceneRouteTrace': true,
    'lineageProfiles': profileIds.length,
    'lineageEvidence': lineageEvidence,
    'lineageEndingEvidence': lineageEndingEvidence,
    'lineageCompanionEvidence': lineageCompanionEvidence,
  };
  final reportFile = File('build/benchmark-verdict.json')
    ..parent.createSync(recursive: true);
  reportFile.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(report)}\n');
  stdout.writeln(
      'TRILEMMA_PERFORMANCE_OK: campaigns=$campaigns transitions=$transitions events=${(source['events'] as List).length} locations=${first.locations.length} lineages=$lineageSummary ms=${millis.toStringAsFixed(1)} endings=${first.endings.length} signatures=${first.signatures.length} companionScenes=${first.companionScenes.length} choiceModes=${first.companionChoiceModes.toList()..sort()} checksum=${first.checksum} replayChecksum=${replay.checksum} forecastChecksum=${first.forecastChecksum} replayForecastChecksum=${replay.forecastChecksum} companionSceneChecksum=${first.companionSceneChecksum} replayCompanionSceneChecksum=${replay.companionSceneChecksum}');
  if (!approved) {
    stderr.writeln(
        'TRILEMMA_PERFORMANCE_FAIL: deterministic core budget or checksum drift');
    exit(1);
  }
}
