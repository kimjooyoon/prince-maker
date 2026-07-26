import 'dart:io';
import 'package:prince_maker/game_core.dart';

int runCampaigns(int campaigns) {
  var checksum = 0;
  for (var i = 0; i < campaigns; i++) {
    final world = GameWorld();
    for (var week = 0; week < 12; week++) {
      world.dispatch(ActivityChosen(week.isEven ? '지혜' : '공감', 2, 1, 1));
      world.dispatch(const WeekAdvanced());
    }
    checksum += world.progress[0]!.week + world.stats[0]!.values['지혜']!;
  }
  return checksum;
}

void main() {
  const campaigns = 5000;
  final watch = Stopwatch()..start();
  final checksum = runCampaigns(campaigns);
  watch.stop();
  final replayChecksum = runCampaigns(campaigns);
  final millis = watch.elapsedMicroseconds / 1000;
  final transitions = campaigns * 24;
  stdout.writeln('TRILEMMA_PERFORMANCE_OK: campaigns=$campaigns transitions=$transitions ms=${millis.toStringAsFixed(1)} checksum=$checksum replayChecksum=$replayChecksum');
  if (millis > 5000 || checksum != campaigns * (13 + 14) || replayChecksum != checksum) {
    stderr.writeln('TRILEMMA_PERFORMANCE_FAIL: deterministic core budget or checksum drift');
    exit(1);
  }
}
