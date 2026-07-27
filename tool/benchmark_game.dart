import 'dart:convert';
import 'dart:io';
import 'package:prince_maker/game_core.dart';

class CampaignMetrics {
  CampaignMetrics(this.checksum, this.endings, this.signatures);
  final int checksum;
  final Set<String> endings, signatures;
}

CampaignMetrics runCampaigns(Map<String, dynamic> source, int campaigns) {
  var checksum = 0;
  final endings = <String>{}, signatures = <String>{};
  final story = JsonStoryAdapter(source);
  for (var i = 0; i < campaigns; i++) {
    final session = GameSession(story, MemorySaveAdapter());
    while (session.world.progress[0]!.week < story.endingWeek) {
      final week = session.world.progress[0]!.week;
      final stat = switch ((i + week) % 3) { 0 => '지혜', 1 => '공감', _ => '용기' };
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
                    (session.world.progress[0]!.bonds[c['requiresBondId']] ?? 0) >=
                        (c['requiresBondMin'] as int? ?? 0)))
            .toList();
        final choice = available[(i + week) % available.length];
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
          line: choice['line'] ?? '',
        ));
      }
    }
    final p = session.world.progress[0]!;
    final ending = resolveEnding(story, session.world.stats[0]!.values,
        bonds: p.bonds, milestones: p.milestones);
    endings.add('${ending['id']}');
    signatures.add(
        '${ending['id']}|${session.world.stats[0]!.values}|${p.bonds}|${p.milestones.values.where((v) => v).length}');
    checksum += p.week +
        session.world.stats[0]!.values.values.reduce((a, b) => a + b) +
        p.bonds.values.reduce((a, b) => a + b) +
        p.trace.length;
  }
  return CampaignMetrics(checksum, endings, signatures);
}

void main() {
  const campaigns = 5000;
  final source = jsonDecode(File('story/story.json').readAsStringSync())
      as Map<String, dynamic>;
  final watch = Stopwatch()..start();
  final first = runCampaigns(source, campaigns);
  watch.stop();
  final replay = runCampaigns(source, campaigns);
  final millis = watch.elapsedMicroseconds / 1000;
  final transitions = campaigns * ((source['endingWeek'] as int) - 1 +
      (source['events'] as List).length);
  stdout.writeln(
      'TRILEMMA_PERFORMANCE_OK: campaigns=$campaigns transitions=$transitions events=${(source['events'] as List).length} ms=${millis.toStringAsFixed(1)} endings=${first.endings.length} signatures=${first.signatures.length} checksum=${first.checksum} replayChecksum=${replay.checksum}');
  if (millis > 5000 ||
      first.checksum <= campaigns ||
      replay.checksum != first.checksum ||
      replay.endings.length != first.endings.length ||
      replay.signatures.length != first.signatures.length ||
      first.signatures.length < 3) {
    stderr.writeln(
        'TRILEMMA_PERFORMANCE_FAIL: deterministic core budget or checksum drift');
    exit(1);
  }
}
