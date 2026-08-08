import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/game_core.dart';
import 'package:prince_maker/save_state.dart';

void main() {
  test('SystemDecisionPolicy owns approval and records a replay receipt', () {
    final approved = SystemDecisionPolicy.evaluate(
        kind: 'activity',
        subject: '별 관측',
        week: 1,
        endingWeek: 24,
        conditions: true,
        owner: 'Lumen Ledger System',
        contract: 'lumen-ledger');
    final rejected = SystemDecisionPolicy.evaluate(
        kind: 'activity',
        subject: 'stale input',
        week: 24,
        endingWeek: 24,
        conditions: true,
        owner: 'Lumen Ledger System',
        contract: 'lumen-ledger');
    expect(approved.approved, isTrue);
    expect(approved.trace, contains('approval:approved'));
    expect(approved.trace, contains('decisionHash:'));
    expect(rejected.approved, isFalse);
    expect(rejected.rule, 'terminal-window');
  });

  test('GameSession commits the system receipt before state transition', () {
    final story = JsonStoryAdapter({
      'events': [],
      'endings': [],
      'companions': [],
      'milestones': [],
      'personalities': [],
      'endingWeek': 12,
      'decisionSystem': {
        'id': 'test-ledger',
        'owner': 'test-system',
      }
    });
    final session = GameSession(story, MemorySaveAdapter());
    session.choose(const ActivityChosen('지혜', 1, 0, 0, label: '기록'));
    expect(session.world.progress[0]!.trace.first,
        startsWith('approval:approved|owner:test-system'));
    session.world.progress[0]!.week = 12;
    session.choose(const ActivityChosen('지혜', 1, 0, 0, label: 'stale'));
    expect(session.world.progress[0]!.trace.last,
        startsWith('approval:rejected|owner:test-system'));
    expect(session.world.stats[0]!.values['지혜'], 5);
  });

  test('same stats resolve to the same authored ending', () {
    final story = JsonStoryAdapter({
      'events': [],
      'endings': [
        {'id': 'a', 'stat': '지혜', 'min': 12, 'title': '별'},
        {'id': 'a+', 'stat': '지혜', 'min': 24, 'title': '새벽'},
        {'id': 'b', 'stat': '공감', 'title': '정원'},
        {'id': 'c', 'stat': '용기', 'title': '길'}
      ]
    });
    expect(resolveEnding(story, {'지혜': 12, '공감': 6, '용기': 4})['id'], 'a');
    expect(resolveEnding(story, {'지혜': 24, '공감': 6, '용기': 4})['id'], 'a+');
    expect(resolveEnding(story, {'지혜': 12, '공감': 6, '용기': 4})['id'], 'a');
  });
  test('master ending requires its authored seasonal goals', () {
    final story = JsonStoryAdapter({
      'personalities': [],
      'events': [],
      'companions': [],
      'milestones': [
        {'id': 'spring', 'week': 3}
      ],
      'endings': [
        {'id': 'basic', 'stat': '지혜', 'min': 12},
        {
          'id': 'master',
          'stat': '지혜',
          'min': 24,
          'requiresMilestones': ['spring']
        }
      ]
    });
    expect(
        resolveEnding(story, {'지혜': 30, '공감': 1, '용기': 1},
            milestones: {'spring': false})['id'],
        'basic');
    expect(
        resolveEnding(story, {'지혜': 30, '공감': 1, '용기': 1},
            milestones: {'spring': true})['id'],
        'master');
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
    world.dispatch(
        const StoryChoiceMade('공감', 2, 0, '등불', bondId: 'bora', bondDelta: 4));
    expect(world.progress[0]!.bonds['bora'], 4);
    expect(world.snapshot().history.single, contains('bond:bora+4'));
  });
  test('rival bond choice preserves relationship opportunity cost in trace',
      () {
    final world = GameWorld();
    world.progress[0]!.bonds['taro'] = 5;
    world.progress[0]!.bonds['bora'] = 4;
    world.dispatch(const StoryChoiceMade('용기', 2, 0, '풍차',
        bondId: 'taro',
        bondDelta: 2,
        rivalId: 'bora',
        rivalDelta: -1,
        line: '바람'));
    expect(world.progress[0]!.bonds['taro'], 7);
    expect(world.progress[0]!.bonds['bora'], 3);
    expect(world.progress[0]!.trace.last,
        'event:풍차|bond:taro+2|rival:bora-1|line:바람');
  });
  test('mediation restores a rival bond and records a new choice space', () {
    final world = GameWorld();
    world.progress[0]!.bonds['taro'] = 4;
    world.dispatch(const StoryChoiceMade('공감', 1, -2, '중재',
        bondId: 'bora',
        bondDelta: 1,
        rivalId: 'taro',
        rivalDelta: 1,
        setsFlag: 'windmill-truce'));
    expect(world.progress[0]!.bonds['bora'], 1);
    expect(world.progress[0]!.bonds['taro'], 5);
    expect(world.progress[0]!.flags['windmill-truce'], isTrue);
    expect(world.progress[0]!.trace.last,
        'event:중재|bond:bora+1|rival:taro1|flag:windmill-truce');
  });
  test('discovering a new location is deterministic and replayable', () {
    final story = JsonStoryAdapter({
      'personalities': [],
      'companions': [],
      'endings': [],
      'milestones': [],
      'events': [
        {
          'week': 2,
          'locationId': 'moon-market',
          'location': '달빛 시장',
          'choices': []
        }
      ]
    });
    final session = GameSession(story, MemorySaveAdapter());
    session.choose(const ActivityChosen('지혜', 1, 0, 1, label: '기록'));
    expect(session.world.progress[0]!.flags['place:moon-market'], isTrue);
    expect(session.world.progress[0]!.trace, contains('location:moon-market'));
    final before = session.world.progress[0]!.trace.length;
    session.choose(const ActivityChosen('지혜', 1, 0, 1, label: '기록'));
    expect(
        session.world.progress[0]!.trace
            .where((e) => e == 'location:moon-market')
            .length,
        1);
    expect(session.world.progress[0]!.trace.length, greaterThan(before));
  });
  test('legacy profile seeds the next campaign with deterministic lineage data',
      () {
    final story = JsonStoryAdapter({
      'personalities': [],
      'companions': [],
      'milestones': [],
      'events': [],
      'endings': [],
      'legacyProfiles': [
        {'id': 'stargazer', 'stat': '지혜', 'bonus': 2}
      ]
    });
    final session = GameSession(story, MemorySaveAdapter(),
        legacyUnlocked: true, legacyId: 'stargazer');
    expect(session.world.stats[0]!.values['지혜'], 6);
    expect(session.world.progress[0]!.flags['legacy-star'], isTrue);
    expect(session.world.progress[0]!.flags['legacy:stargazer'], isTrue);
    expect(session.world.progress[0]!.trace, ['legacy:stargazer|지혜+2']);
  });
  test('legacy profile changes an authored choice outcome and trace', () {
    final story = JsonStoryAdapter({
      'personalities': [],
      'companions': [],
      'milestones': [],
      'events': [],
      'endings': [],
      'legacyProfiles': [
        {'id': 'stargazer', 'stat': '지혜', 'bonus': 2}
      ]
    });
    final session = GameSession(story, MemorySaveAdapter(),
        legacyUnlocked: true, legacyId: 'stargazer');
    session.chooseEvent(const StoryChoiceMade('공감', 1, 0, '기록 공유',
        legacyId: 'stargazer',
        legacyBonuses: {
          'stargazer': {'stat': '지혜', 'delta': 1}
        }));
    expect(session.world.stats[0]!.values, {'지혜': 7, '공감': 6, '용기': 3});
    expect(session.world.progress[0]!.trace.last, 'event:기록 공유|legacy:지혜+1');
  });
  test('selected personality gives a deterministic focus bonus', () {
    final story = JsonStoryAdapter({
      'personalities': [
        {'focusStat': '지혜', 'focusBonus': 1}
      ],
      'endings': [],
      'events': [],
      'companions': []
    });
    final session = GameSession(story, MemorySaveAdapter());
    session.choose(const ActivityChosen('지혜', 3, 0, 1, label: '별 관측'));
    expect(session.world.stats[0]!.values['지혜'], 8);
    expect(session.world.progress[0]!.lastResult, contains('성격 재능 +1'));
  });
  test('rest does not turn a personality talent into free growth', () {
    final story = JsonStoryAdapter({
      'personalities': [
        {'focusStat': '지혜', 'focusBonus': 1}
      ],
      'endings': [],
      'events': [],
      'companions': []
    });
    final session = GameSession(story, MemorySaveAdapter());
    session.choose(const ActivityChosen('지혜', 0, 0, -2, label: '달빛 아래 휴식'));
    expect(session.world.stats[0]!.values['지혜'], 4);
    expect(session.world.progress[0]!.lastResult, isNot(contains('재능')));
  });
  test('bond threshold adds a deterministic companion epilogue', () {
    final story = JsonStoryAdapter({
      'personalities': [],
      'events': [],
      'companions': [
        {'id': 'lumi', 'bondThreshold': 8, 'epilogue': '별표'}
      ],
      'endings': [
        {'id': 'a', 'stat': '지혜', 'min': 1, 'title': '별'}
      ]
    });
    expect(
        resolveEnding(story, {'지혜': 2}, bonds: {'lumi': 8})['epilogue'], '별표');
  });
  test('all threshold companions become deterministic ending epilogues', () {
    final story = JsonStoryAdapter({
      'personalities': [],
      'events': [],
      'companions': [
        {'id': 'lumi', 'bondThreshold': 8, 'epilogue': '별표'},
        {'id': 'bora', 'bondThreshold': 8, 'epilogue': '씨앗표'}
      ],
      'endings': [
        {'id': 'a', 'stat': '지혜', 'min': 1, 'title': '별'}
      ]
    });
    final result =
        resolveEnding(story, {'지혜': 2}, bonds: {'lumi': 8, 'bora': 9});
    expect(result['epilogue'], '씨앗표');
    expect((result['epilogues'] as List).map((e) => e['text']), ['별표', '씨앗표']);
  });
  test('ending rank rewards authored goals and companion bonds', () {
    final story = JsonStoryAdapter({
      'personalities': [],
      'events': [],
      'companions': [
        {'id': 'lumi', 'bondThreshold': 8}
      ],
      'milestones': [
        {'id': 'spring'}
      ],
      'endings': [
        {'id': 'a', 'stat': '지혜', 'min': 1}
      ]
    });
    expect(
        resolveEnding(story, {'지혜': 2},
            milestones: {'spring': false}, bonds: {'lumi': 0})['rank'],
        1);
    expect(
        resolveEnding(story, {'지혜': 2},
            milestones: {'spring': true}, bonds: {'lumi': 8})['rank'],
        3);
  });
  test('season milestone resolves once with its authored reward', () {
    final story = JsonStoryAdapter({
      'personalities': [],
      'events': [],
      'companions': [],
      'milestones': [
        {
          'id': 'spring',
          'week': 3,
          'title': '봄',
          'stat': '지혜',
          'min': 8,
          'coins': 3,
          'pass': '달성',
          'fail': '실패'
        }
      ],
      'endings': []
    });
    final session = GameSession(story, MemorySaveAdapter());
    for (var i = 0; i < 2; i++)
      session.choose(const ActivityChosen('지혜', 2, 0, 0, label: '관측'));
    expect(session.world.progress[0]!.milestones['spring'], isTrue);
    expect(session.world.progress[0]!.coins, 15);
    expect(
        session.world
            .snapshot()
            .history
            .where((e) => e.startsWith('milestone:'))
            .length,
        1);
  });
  test('event choice resolves the milestone after its stat contribution', () {
    final story = JsonStoryAdapter({
      'personalities': [],
      'companions': [],
      'endings': [],
      'events': [
        {
          'week': 3,
          'choices': [
            {'stat': '지혜', 'delta': 2, 'coins': 0, 'label': '별'}
          ]
        }
      ],
      'milestones': [
        {
          'id': 'spring',
          'week': 3,
          'title': '봄',
          'stat': '지혜',
          'min': 8,
          'coins': 3,
          'pass': '달성',
          'fail': '실패'
        }
      ]
    });
    final session = GameSession(story, MemorySaveAdapter());
    session.choose(const ActivityChosen('지혜', 2, 0, 0));
    session.choose(const ActivityChosen('지혜', 2, 0, 0));
    session.chooseEvent(const StoryChoiceMade('지혜', 2, 0, '별'));
    expect(session.world.progress[0]!.milestones['spring'], isTrue);
  });
  test('event dialogue is part of the deterministic replay trace', () {
    final world = GameWorld();
    world.dispatch(const StoryChoiceMade('공감', 2, 0, '등불',
        bondId: 'bora', bondDelta: 4, line: '작은 빛도 함께라면 길이 돼.'));
    expect(world.progress[0]!.lastLine, '작은 빛도 함께라면 길이 돼.');
    expect(world.snapshot().replayTrace, contains('line:작은 빛도 함께라면 길이 돼.'));
  });
  test('ending retrospective keeps authored causes in deterministic order', () {
    final world = GameWorld();
    world.dispatch(const StoryChoiceMade('지혜', 1, 0, '첫 별'));
    world.dispatch(const StoryChoiceMade('공감', 1, 0, '두 번째 정원'));
    world.dispatch(
        const MilestoneResolved('spring', '봄', '지혜', 1, 2, '달성', '실패'));
    final trace = world.snapshot().history;
    expect(trace.where((entry) => entry.startsWith('event:')).toList(), [
      'event:첫 별',
      'event:두 번째 정원',
    ]);
    expect(trace.where((entry) => entry.startsWith('milestone:')).single,
        'milestone:spring:pass');
  });
  test('core rejects a locked choice even without the UI adapter', () {
    final story = JsonStoryAdapter({
      'personalities': [],
      'companions': [],
      'endings': [],
      'events': [],
      'milestones': []
    });
    final session = GameSession(story, MemorySaveAdapter());
    session.chooseEvent(const StoryChoiceMade('용기', 9, 0, '잠긴 길',
        requiresStat: '지혜', requiresMin: 99));
    expect(session.world.stats[0]!.values['용기'], 3);
    expect(session.world.progress[0]!.lastResult, contains('조건 부족'));
  });
  test('core gates a relationship choice deterministically', () {
    final story = JsonStoryAdapter({
      'personalities': [],
      'companions': [],
      'endings': [],
      'events': [],
      'milestones': []
    });
    final session = GameSession(story, MemorySaveAdapter());
    session.chooseEvent(const StoryChoiceMade('용기', 1, -2, '이름 없는 길',
        bondId: 'taro',
        bondDelta: 3,
        requiresBondId: 'taro',
        requiresBondMin: 2));
    expect(session.world.stats[0]!.values['용기'], 3);
    expect(session.world.progress[0]!.lastResult, contains('관계 조건 부족'));
    session.world.progress[0]!.bonds['taro'] = 2;
    session.chooseEvent(const StoryChoiceMade('용기', 1, -2, '이름 없는 길',
        bondId: 'taro',
        bondDelta: 3,
        requiresBondId: 'taro',
        requiresBondMin: 2));
    expect(session.world.stats[0]!.values['용기'], 4);
    expect(session.world.progress[0]!.bonds['taro'], 5);
  });
  test('core gates a memory choice and records the authored flag', () {
    final story = JsonStoryAdapter({
      'personalities': [],
      'companions': [],
      'endings': [],
      'events': [],
      'milestones': []
    });
    final session = GameSession(story, MemorySaveAdapter());
    session.chooseEvent(const StoryChoiceMade('용기', 1, 0, '기억을 잇기',
        requiresFlag: 'windmill-repair', setsFlag: 'festival-stage'));
    expect(session.world.stats[0]!.values['용기'], 3);
    expect(session.world.progress[0]!.lastResult, contains('기억 조건 부족'));
    session.world.progress[0]!.flags['windmill-repair'] = true;
    session.chooseEvent(const StoryChoiceMade('용기', 1, 0, '기억을 잇기',
        requiresFlag: 'windmill-repair', setsFlag: 'festival-stage'));
    expect(session.world.stats[0]!.values['용기'], 4);
    expect(session.world.progress[0]!.flags['festival-stage'], isTrue);
    expect(
        session.world.snapshot().replayTrace, contains('flag:festival-stage'));
  });
  test('legacy collection seed deterministically unlocks a new choice space',
      () {
    final story = JsonStoryAdapter({
      'personalities': [],
      'companions': [],
      'endings': [],
      'events': [],
      'milestones': []
    });
    final fresh = GameSession(story, MemorySaveAdapter());
    final legacy =
        GameSession(story, MemorySaveAdapter(), legacyUnlocked: true);
    expect(fresh.world.progress[0]!.flags['legacy-star'], isNull);
    expect(legacy.world.progress[0]!.flags['legacy-star'], isTrue);
    expect(legacy.world.snapshot().replayTrace, 'legacy:star');
  });
  test('coin balance is bounded when an event has a cost', () {
    final world = GameWorld()..progress[0]!.coins = 1;
    world.dispatch(const StoryChoiceMade('공감', 0, -5, '비용이 큰 선택'));
    expect(world.progress[0]!.coins, 0);
  });
  test('completed campaign is terminal until a new session is created', () {
    final story = JsonStoryAdapter({
      'personalities': [],
      'companions': [],
      'milestones': [],
      'events': [],
      'endings': []
    });
    final session = GameSession(story, MemorySaveAdapter());
    session.world.progress[0]!.week = 12;
    session.choose(const ActivityChosen('지혜', 99, 99, 0, label: '불가능한 추가 주차'));
    expect(session.world.stats[0]!.values['지혜'], 4);
    expect(session.world.progress[0]!.coins, 12);
    expect(session.world.progress[0]!.lastResult, contains('기록이 완성되었습니다'));
  });
  test('completed campaign rejects stale event input too', () {
    final story = JsonStoryAdapter({
      'personalities': [],
      'companions': [],
      'milestones': [],
      'events': [],
      'endings': []
    });
    final session = GameSession(story, MemorySaveAdapter());
    session.world.progress[0]!.week = 12;
    session.chooseEvent(const StoryChoiceMade('용기', 99, 99, '늦은 사건'));
    expect(session.world.stats[0]!.values['용기'], 3);
    expect(session.world.progress[0]!.coins, 12);
    expect(session.world.progress[0]!.lastResult, contains('기록이 완성되었습니다'));
  });
  test('activity and event commands automatically persist the latest snapshot',
      () {
    final save = MemorySaveAdapter();
    final story = JsonStoryAdapter({
      'personalities': [],
      'companions': [],
      'milestones': [],
      'events': [
        {
          'week': 2,
          'choices': [
            {'stat': '공감', 'delta': 1, 'coins': 0, 'label': '등불'}
          ]
        }
      ],
      'endings': []
    });
    final session = GameSession(story, save);
    session.choose(const ActivityChosen('지혜', 2, 0, 0, label: '관측'));
    expect(GameSnapshot.decode(save.read()!).week, 2);
    session.chooseEvent(const StoryChoiceMade('공감', 1, 0, '등불'));
    final restored = GameSnapshot.decode(save.read()!);
    expect(restored.stats['공감'], 6);
    expect(restored.replayTrace, contains('event:등불'));
  });
  test('restore returns the saved page for reload continuity', () {
    final save = MemorySaveAdapter();
    final story = JsonStoryAdapter({
      'personalities': [],
      'companions': [],
      'milestones': [],
      'events': [],
      'endings': []
    });
    final source = GameSession(story, save);
    source.persist(page: 2);
    final restored = GameSession(story, save);
    expect(restored.restore()!.page, 2);
    expect(restored.snapshot().week, 1);
  });
  test('starting a new campaign clears the previous save adapter state', () {
    final save = MemorySaveAdapter()..write('old');
    save.clear();
    expect(save.read(), isNull);
  });
}
