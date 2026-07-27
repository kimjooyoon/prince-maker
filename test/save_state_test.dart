import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/save_state.dart';

void main() {
  test('save round trip preserves replay trace and state', () {
    const source = GameSnapshot(week: 8, coins: 17, fatigue: 4, selected: 2, persona: 1, page: 0, eventIndex: 1, stats: {'지혜': 9, '공감': 7, '용기': 8}, bonds: {'lumi': 4, 'bora': 8, 'taro': 0}, milestones: {'spring': true, 'summer': false}, flags: {'windmill-repair': true}, lastResult: '공방 돕기 · 용기 +2 · 피로 +1', lastLine: '떨려도, 한 걸음은 내 것이야.', history: ['공방 돕기', 'event:먼저 발을 내딛는다|line:떨려도, 한 걸음은 내 것이야.']);
    final restored = GameSnapshot.decode(source.encode());
    expect(restored.toJson(), source.toJson());
    expect(restored.replayTrace, '공방 돕기>event:먼저 발을 내딛는다|line:떨려도, 한 걸음은 내 것이야.');
  });
}
