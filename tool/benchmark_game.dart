import 'dart:convert';
import 'dart:io';
import 'package:prince_maker/game_core.dart';

int runCampaigns(Map<String, dynamic> source, int campaigns) {
  var checksum = 0;
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
                c['requiresStat'] == null ||
                (session.world.stats[0]!.values[c['requiresStat']] ?? 0) >=
                    (c['requiresMin'] as int? ?? 0))
            .toList();
        final choice = available[(i + week) % available.length];
        session.chooseEvent(StoryChoiceMade(
          choice['stat'],
          choice['delta'],
          choice['coins'],
          choice['label'],
          bondId: choice['bondId'],
          bondDelta: choice['bondDelta'],
          requiresStat: choice['requiresStat'],
          requiresMin: choice['requiresMin'] ?? 0,
          line: choice['line'] ?? '',
        ));
      }
    }
    final p = session.world.progress[0]!;
    checksum += p.week +
        session.world.stats[0]!.values.values.reduce((a, b) => a + b) +
        p.bonds.values.reduce((a, b) => a + b) +
        p.trace.length;
  }
  return checksum;
}

void main() {
  const campaigns = 5000;
  final source = jsonDecode(File('story/story.json').readAsStringSync())
      as Map<String, dynamic>;
  final watch = Stopwatch()..start();
  final checksum = runCampaigns(source, campaigns);
  watch.stop();
  final replayChecksum = runCampaigns(source, campaigns);
  final millis = watch.elapsedMicroseconds / 1000;
  final transitions = campaigns * (11 + 8);
  stdout.writeln(
      'TRILEMMA_PERFORMANCE_OK: campaigns=$campaigns transitions=$transitions events=8 ms=${millis.toStringAsFixed(1)} checksum=$checksum replayChecksum=$replayChecksum');
  if (millis > 5000 || checksum <= campaigns || replayChecksum != checksum) {
    stderr.writeln(
        'TRILEMMA_PERFORMANCE_FAIL: deterministic core budget or checksum drift');
    exit(1);
  }
}
