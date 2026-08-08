import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/activity_catalog.dart';

void main() {
  test('story activity catalog preserves authored order and tradeoffs', () {
    final activities = activitiesFromStory({
      'activities': [
        {
          'label': 'A',
          'icon': '✦',
          'hint': '지혜 +2',
          'stat': '지혜',
          'delta': 2,
          'fatigue': 1,
          'coins': 0
        },
        {
          'label': 'B',
          'icon': '◇',
          'hint': '은화 +3',
          'stat': '공감',
          'delta': 0,
          'fatigue': -1,
          'coins': 3
        },
      ],
    });
    expect(activities.map((a) => a.label), ['A', 'B']);
    expect(activities.map((a) => [a.stat, a.delta, a.fatigue, a.coins]), [
      ['지혜', 2, 1, 0],
      ['공감', 0, -1, 3],
    ]);
  });

  test('missing story activities use the five-action default contract', () {
    expect(activitiesFromStory({}), hasLength(5));
    expect(activitiesFromStory({}).map((activity) => activity.stat).toSet(),
        {'지혜', '공감', '용기'});
  });
}
