import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/game_core.dart';
import 'package:prince_maker/star_cellar.dart';
import 'package:prince_maker/star_cellar_painter.dart';

void main() {
  test('deterministic replay keeps the same room trace', () {
    const actions = [
      CellarAction.up,
      CellarAction.left,
      CellarAction.pulse,
      CellarAction.right,
      CellarAction.up,
      CellarAction.down,
      CellarAction.left,
    ];
    CellarState replay(int seed) => actions.fold(
        StarCellarEngine.initial(seed: seed), StarCellarEngine.step);

    final first = replay(41), second = replay(41);
    expect(first.fingerprint, second.fingerprint);
    expect(first.trace.length, lessThanOrEqualTo(actions.length + 1));
    expect(first.player.x, inInclusiveRange(0, StarCellarEngine.width - 1));
    expect(first.player.y, inInclusiveRange(0, StarCellarEngine.height - 1));
  });

  test('system adjudication records a cleared mini-game reward', () {
    final session = GameSession(
        JsonStoryAdapter({
          'miniGameContract': {'id': 'star-cellar', 'rewardCoins': 2},
        }),
        MemorySaveAdapter());
    session.completeStarCellar(score: 287, turn: 13);
    final progress = session.world.progress[0]!;
    expect(progress.flags['star-cellar-cleared'], isTrue);
    expect(progress.coins, 14);
    expect(progress.trace.last, contains('mini-game:star-cellar'));
  });

  test('Canvas controls map to one deterministic action each', () {
    for (final entry in StarCellarPainter.actionRects.entries)
      expect(StarCellarPainter.actionAt(entry.value.center), entry.key);
    expect(StarCellarPainter.backAt(const Offset(80, 660)), isTrue);
  });
}
