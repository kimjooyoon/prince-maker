import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/save_state.dart';

void main() {
  test('save round trip preserves replay trace and state', () {
    const source = GameSnapshot(
        week: 8,
        coins: 17,
        fatigue: 4,
        selected: 2,
        persona: 1,
        page: 0,
        eventIndex: 1,
        stats: {'지혜': 9, '공감': 7, '용기': 8},
        bonds: {'lumi': 4, 'bora': 8, 'taro': 0},
        milestones: {'spring': true, 'summer': false},
        flags: {'windmill-repair': true},
        lastResult: '공방 돕기 · 용기 +2 · 피로 +1',
        lastLine: '떨려도, 한 걸음은 내 것이야.',
        history: ['공방 돕기', 'event:먼저 발을 내딛는다|line:떨려도, 한 걸음은 내 것이야.']);
    final restored = GameSnapshot.decode(source.encode());
    expect(restored.toJson(), source.toJson());
    expect(
        restored.replayTrace, '공방 돕기>event:먼저 발을 내딛는다|line:떨려도, 한 걸음은 내 것이야.');
  });

  test('save round trip preserves player-facing archive positions', () {
    const source = GameSnapshot(
      week: 48,
      coins: 12,
      fatigue: 2,
      selected: 1,
      persona: 2,
      page: 13,
      eventIndex: 46,
      stats: {'지혜': 10, '공감': 8, '용기': 12},
      bonds: {'lumi': 2, 'bora': 5, 'taro': 8},
      history: ['companion-scene:bora-shared-water'],
      sideSceneCursor: 7,
      companionSceneIndex: 2,
      pendingCompanionSceneId: 'taro-next-foothold',
      archiveCharacterIndex: 14,
      archiveEmotionIndex: 3,
      locale: 'en',
      selectedLegacyId: 'pathfinder',
    );

    final restored = GameSnapshot.decode(source.encode());
    expect(restored.toJson(), source.toJson());
    expect(restored.sideSceneCursor, 7);
    expect(restored.companionSceneIndex, 2);
    expect(restored.pendingCompanionSceneId, 'taro-next-foothold');
    expect(restored.archiveCharacterIndex, 14);
    expect(restored.archiveEmotionIndex, 3);
    expect(restored.locale, 'en');
    expect(restored.selectedLegacyId, 'pathfinder');
  });

  test('legacy save without UI state keeps stable defaults', () {
    const raw =
        '{"schema":"lumen-save-v7","week":1,"coins":12,"fatigue":0,"selected":0,"page":13,"persona":0,"eventIndex":0,"stats":{"지혜":4,"공감":5,"용기":3},"history":[]}';
    final restored = GameSnapshot.decode(raw);
    expect(restored.sideSceneCursor, 0);
    expect(restored.companionSceneIndex, 0);
    expect(restored.pendingCompanionSceneId, isNull);
    expect(restored.locale, 'ko');
  });
}
