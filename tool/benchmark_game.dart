import 'dart:io';
import 'package:prince_maker/game_core.dart';

void main() {
  const campaigns = 5000;
  final watch = Stopwatch()..start();
  var checksum = 0;
  for (var i = 0; i < campaigns; i++) {
    final world = GameWorld();
    for (var week = 0; week < 12; week++) {
      world.dispatch(ActivityChosen(week.isEven ? '지혜' : '공감', 2, 1, 1));
      world.dispatch(const WeekAdvanced());
    }
    checksum += world.progress[0]!.week + world.stats[0]!.values['지혜']!;
  }
  watch.stop();
  final millis = watch.elapsedMicroseconds / 1000;
  final transitions = campaigns * 24;
  stdout.writeln('TRILEMMA_PERFORMANCE_OK: campaigns=$campaigns transitions=$transitions ms=${millis.toStringAsFixed(1)} checksum=$checksum');
  if (millis > 5000 || checksum != campaigns * (13 + 14)) {
    stderr.writeln('TRILEMMA_PERFORMANCE_FAIL: deterministic core budget or checksum drift');
    exit(1);
  }
}
