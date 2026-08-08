import 'dart:convert';
import 'dart:io';
import 'package:prince_maker/game_core.dart';

class CampaignMetrics {
  CampaignMetrics(this.checksum, this.endings, this.signatures, this.locations,
      this.lineageEndings, this.lineageSignatures, this.lineageCompanions);
  final int checksum;
  final Set<String> endings, signatures, locations;
  final Map<String, Set<String>> lineageEndings,
      lineageSignatures,
      lineageCompanions;
}

CampaignMetrics runCampaigns(Map<String, dynamic> source, int campaigns) {
  var checksum = 0;
  final endings = <String>{}, signatures = <String>{}, locations = <String>{};
  final lineageEndings = <String, Set<String>>{},
      lineageSignatures = <String, Set<String>>{},
      lineageCompanions = <String, Set<String>>{};
  final story = JsonStoryAdapter(source);
  final legacyIds = story.legacyProfiles.map((p) => '${p['id']}').toList();
  for (var i = 0; i < campaigns; i++) {
    final legacyId = i.isEven && legacyIds.isNotEmpty
        ? legacyIds[i % legacyIds.length]
        : null;
    final session = GameSession(story, MemorySaveAdapter(),
        legacyUnlocked: i.isEven, legacyId: legacyId);
    final legacyProfile = legacyId == null
        ? null
        : story.legacyProfiles.firstWhere((p) => p['id'] == legacyId);
    while (session.world.progress[0]!.week < story.endingWeek) {
      final week = session.world.progress[0]!.week;
      final stat = legacyProfile?['stat'] as String? ??
          switch ((i + week) % 3) { 0 => '지혜', 1 => '공감', _ => '용기' };
      session.choose(ActivityChosen(stat, 2, 1, 1, label: 'benchmark:$stat'));
      final event = story.events
          .where((e) => e['week'] == session.world.progress[0]!.week)
          .firstOrNull;
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
    final ending = resolveEnding(story, session.world.stats[0]!.values,
        bonds: p.bonds, milestones: p.milestones);
    endings.add('${ending['id']}');
    locations.addAll(p.flags.keys.where((key) => key.startsWith('place:')));
    final signature =
            '${ending['id']}|${session.world.stats[0]!.values}|${p.bonds}|${p.milestones.values.where((v) => v).length}|${p.flags}',
        lineage = session.legacyId ?? 'none';
    signatures.add(signature);
    lineageEndings
        .putIfAbsent(lineage, () => <String>{})
        .add('${ending['id']}');
    lineageSignatures.putIfAbsent(lineage, () => <String>{}).add(signature);
    lineageCompanions.putIfAbsent(lineage, () => <String>{}).addAll(
        ((ending['epilogues'] as List?) ?? const [])
            .map((route) => '${(route as Map)['id']}'));
    checksum += p.week +
        session.world.stats[0]!.values.values.reduce((a, b) => a + b) +
        p.bonds.values.reduce((a, b) => a + b) +
        p.trace.length;
  }
  return CampaignMetrics(checksum, endings, signatures, locations,
      lineageEndings, lineageSignatures, lineageCompanions);
}

void main() {
  const campaigns = 5000;
  final source = jsonDecode(File('story/story.json').readAsStringSync())
      as Map<String, dynamic>;
  final story = JsonStoryAdapter(source);
  final watch = Stopwatch()..start();
  final first = runCampaigns(source, campaigns);
  watch.stop();
  final replay = runCampaigns(source, campaigns);
  final millis = watch.elapsedMicroseconds / 1000;
  final transitions = campaigns *
      ((source['endingWeek'] as int) - 1 + (source['events'] as List).length);
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
  stdout.writeln(
      'TRILEMMA_PERFORMANCE_OK: campaigns=$campaigns transitions=$transitions events=${(source['events'] as List).length} locations=${first.locations.length} lineages=$lineageSummary ms=${millis.toStringAsFixed(1)} endings=${first.endings.length} signatures=${first.signatures.length} checksum=${first.checksum} replayChecksum=${replay.checksum}');
  if (millis > 8000 ||
      first.checksum <= campaigns ||
      replay.checksum != first.checksum ||
      replay.endings.length != first.endings.length ||
      replay.signatures.length != first.signatures.length ||
      replay.locations.length != first.locations.length ||
      first.locations.length < 4 ||
      first.signatures.length < 3 ||
      !lineageEvidence ||
      !lineageEndingEvidence ||
      !lineageCompanionEvidence ||
      replay.lineageSignatures.toString() !=
          first.lineageSignatures.toString() ||
      replay.lineageCompanions.toString() !=
          first.lineageCompanions.toString()) {
    stderr.writeln(
        'TRILEMMA_PERFORMANCE_FAIL: deterministic core budget or checksum drift');
    exit(1);
  }
}
