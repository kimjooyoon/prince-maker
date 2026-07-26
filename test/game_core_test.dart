import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/game_core.dart';

void main() {
  test('same stats resolve to the same authored ending', () {
    final story = JsonStoryAdapter({'events': [], 'endings': [
      {'id':'a','stat':'지혜','min':12,'title':'별'}, {'id':'a+','stat':'지혜','min':24,'title':'새벽'}, {'id':'b','stat':'공감','title':'정원'}, {'id':'c','stat':'용기','title':'길'}
    ]});
    expect(resolveEnding(story, {'지혜': 12, '공감': 6, '용기': 4})['id'], 'a');
    expect(resolveEnding(story, {'지혜': 24, '공감': 6, '용기': 4})['id'], 'a+');
    expect(resolveEnding(story, {'지혜': 12, '공감': 6, '용기': 4})['id'], 'a');
  });
  test('fatigue is a bounded risk and rest restores it', () {
    final world = GameWorld()..progress[0]!.fatigue = 8;
    world.dispatch(const ActivityChosen('지혜', 3, 0, 1));
    expect(world.stats[0]!.values['지혜'], 6);
    world.dispatch(const ActivityChosen('지혜', 0, 0, -2));
    expect(world.progress[0]!.fatigue, 7);
  });
  test('story choices deterministically grow companion bonds', () {
    final world = GameWorld();
    world.dispatch(const StoryChoiceMade('공감', 2, 0, '등불', bondId: 'bora', bondDelta: 4));
    expect(world.progress[0]!.bonds['bora'], 4);
    expect(world.snapshot().history.single, contains('bond:bora+4'));
  });
}
