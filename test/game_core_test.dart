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
  test('master ending requires its authored seasonal goals', () {
    final story = JsonStoryAdapter({'personalities': [], 'events': [], 'companions': [], 'milestones': [{'id':'spring','week':3}], 'endings': [
      {'id':'basic','stat':'지혜','min':12}, {'id':'master','stat':'지혜','min':24,'requiresMilestones':['spring']}
    ]});
    expect(resolveEnding(story, {'지혜': 30, '공감': 1, '용기': 1}, milestones: {'spring': false})['id'], 'basic');
    expect(resolveEnding(story, {'지혜': 30, '공감': 1, '용기': 1}, milestones: {'spring': true})['id'], 'master');
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
  test('selected personality gives a deterministic focus bonus', () {
    final story = JsonStoryAdapter({'personalities': [{'focusStat':'지혜','focusBonus':1}], 'endings': [], 'events': [], 'companions': []});
    final session = GameSession(story, MemorySaveAdapter());
    session.choose(const ActivityChosen('지혜', 3, 0, 1, label: '별 관측'));
    expect(session.world.stats[0]!.values['지혜'], 8);
    expect(session.world.progress[0]!.lastResult, contains('성격 재능 +1'));
  });
  test('rest does not turn a personality talent into free growth', () {
    final story = JsonStoryAdapter({'personalities': [{'focusStat':'지혜','focusBonus':1}], 'endings': [], 'events': [], 'companions': []});
    final session = GameSession(story, MemorySaveAdapter());
    session.choose(const ActivityChosen('지혜', 0, 0, -2, label: '달빛 아래 휴식'));
    expect(session.world.stats[0]!.values['지혜'], 4);
    expect(session.world.progress[0]!.lastResult, isNot(contains('재능')));
  });
  test('bond threshold adds a deterministic companion epilogue', () {
    final story = JsonStoryAdapter({'personalities': [], 'events': [], 'companions': [{'id':'lumi','bondThreshold':8,'epilogue':'별표'}], 'endings': [{'id':'a','stat':'지혜','min':1,'title':'별'}]});
    expect(resolveEnding(story, {'지혜': 2}, bonds: {'lumi': 8})['epilogue'], '별표');
  });
  test('season milestone resolves once with its authored reward', () {
    final story = JsonStoryAdapter({'personalities': [], 'events': [], 'companions': [], 'milestones': [{'id':'spring','week':3,'title':'봄','stat':'지혜','min':8,'coins':3,'pass':'달성','fail':'실패'}], 'endings': []});
    final session = GameSession(story, MemorySaveAdapter());
    for (var i = 0; i < 2; i++) session.choose(const ActivityChosen('지혜', 2, 0, 0, label: '관측'));
    expect(session.world.progress[0]!.milestones['spring'], isTrue);
    expect(session.world.progress[0]!.coins, 15);
    expect(session.world.snapshot().history.where((e) => e.startsWith('milestone:')).length, 1);
  });
  test('event choice resolves the milestone after its stat contribution', () {
    final story = JsonStoryAdapter({'personalities': [], 'companions': [], 'endings': [], 'events': [{'week':3,'choices':[{'stat':'지혜','delta':2,'coins':0,'label':'별'}]}], 'milestones': [{'id':'spring','week':3,'title':'봄','stat':'지혜','min':8,'coins':3,'pass':'달성','fail':'실패'}]});
    final session = GameSession(story, MemorySaveAdapter());
    session.choose(const ActivityChosen('지혜', 2, 0, 0));
    session.choose(const ActivityChosen('지혜', 2, 0, 0));
    session.chooseEvent(const StoryChoiceMade('지혜', 2, 0, '별'));
    expect(session.world.progress[0]!.milestones['spring'], isTrue);
  });
  test('event dialogue is part of the deterministic replay trace', () {
    final world = GameWorld();
    world.dispatch(const StoryChoiceMade('공감', 2, 0, '등불', bondId: 'bora', bondDelta: 4, line: '작은 빛도 함께라면 길이 돼.'));
    expect(world.progress[0]!.lastLine, '작은 빛도 함께라면 길이 돼.');
    expect(world.snapshot().replayTrace, contains('line:작은 빛도 함께라면 길이 돼.'));
  });
  test('core rejects a locked choice even without the UI adapter', () {
    final story = JsonStoryAdapter({'personalities': [], 'companions': [], 'endings': [], 'events': [], 'milestones': []});
    final session = GameSession(story, MemorySaveAdapter());
    session.chooseEvent(const StoryChoiceMade('용기', 9, 0, '잠긴 길', requiresStat: '지혜', requiresMin: 99));
    expect(session.world.stats[0]!.values['용기'], 3);
    expect(session.world.progress[0]!.lastResult, contains('조건 부족'));
  });
  test('coin balance is bounded when an event has a cost', () {
    final world = GameWorld()..progress[0]!.coins = 1;
    world.dispatch(const StoryChoiceMade('공감', 0, -5, '비용이 큰 선택'));
    expect(world.progress[0]!.coins, 0);
  });
  test('completed campaign is terminal until a new session is created', () {
    final story = JsonStoryAdapter({'personalities': [], 'companions': [], 'milestones': [], 'events': [], 'endings': []});
    final session = GameSession(story, MemorySaveAdapter());
    session.world.progress[0]!.week = 12;
    session.choose(const ActivityChosen('지혜', 99, 99, 0, label: '불가능한 추가 주차'));
    expect(session.world.stats[0]!.values['지혜'], 4);
    expect(session.world.progress[0]!.coins, 12);
    expect(session.world.progress[0]!.lastResult, contains('기록이 완성되었습니다'));
  });
}
