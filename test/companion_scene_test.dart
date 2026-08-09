import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/decision_receipt.dart';
import 'package:prince_maker/game_core.dart';
import 'package:prince_maker/jsonl.dart';

Future<Map<String, dynamic>> loadStory() async => decodeJsonl(utf8
    .decode((await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('companion scene resolver and record loop', () async {
    final story = await loadStory(), model = JsonStoryAdapter(story);
    final first =
        resolveCompanionScenes(model, {'lumi': 1}, {}, currentChapter: 1);
    final rawFirst = model.companionScenes
        .where((scene) => scene['id'] == 'lumi-first-margin')
        .single;
    expect(rawFirst.containsKey('available'), isFalse,
        reason: 'available is a runtime projection, never an SSOT field');
    expect(
        first
            .where((scene) => scene['companionId'] == 'lumi')
            .first['available'],
        true);
    expect(
        first
            .where((scene) => scene['id'] == 'lumi-slow-star')
            .first['available'],
        false);
    expect(first.where((scene) => scene['id'] == 'lumi-first-margin').first,
        containsPair('bondDelta', 1));
    expect(resolveCompanionScenes(model, {'lumi': 1}, {}, currentChapter: 1),
        first);

    GameSession run() {
      final session =
          GameSession(model, MemorySaveAdapter(), autoPersist: false);
      session.world.progress[0]!.bonds['lumi'] = 1;
      return session;
    }

    final a = run(), b = run();
    a.recordCompanionScene('lumi-first-margin');
    b.recordCompanionScene('lumi-first-margin');
    expect(a.snapshot().flags['companion-scene:lumi-first-margin'], true);
    expect(a.snapshot().bonds['lumi'], 2);
    expect(a.snapshot().stats['지혜'], 5);
    expect(a.snapshot().flags['companion-choice:lumi-first-margin:open'], true);
    expect(a.snapshot().history,
        contains('companion-scene:lumi-first-margin|companion:lumi|bond+1'));
    expect(a.snapshot().history, b.snapshot().history);
    expect(a.snapshot().lastLine, b.snapshot().lastLine);

    a.recordCompanionScene('lumi-first-margin');
    b.recordCompanionScene('lumi-first-margin');
    expect(a.snapshot().history, b.snapshot().history);
    expect(
        a
            .snapshot()
            .history
            .where((trace) =>
                trace.startsWith('companion-scene:lumi-first-margin|'))
            .length,
        1);
    expect(a.snapshot().bonds['lumi'], 2);
    expect(recentDecisionReceipts(a.snapshot().history).first.approved, false);

    final locked = GameSession(model, MemorySaveAdapter(), autoPersist: false);
    locked.recordCompanionScene('lumi-first-margin');
    expect(
        locked
            .snapshot()
            .flags
            .containsKey('companion-scene:lumi-first-margin'),
        false);
    expect(locked.snapshot().lastResult, 'companion-scene-rejected:bond');
    expect(recentDecisionReceipts(locked.snapshot().history).single.approved,
        false);

    final chapterLocked = run();
    chapterLocked.recordCompanionScene('lumi-slow-star');
    expect(chapterLocked.snapshot().lastResult,
        'companion-scene-rejected:chapter');

    final duplicate = run();
    duplicate.recordCompanionScene('lumi-first-margin');
    duplicate.recordCompanionScene('lumi-first-margin');
    expect(
        duplicate.snapshot().lastResult, 'companion-scene-rejected:duplicate');

    final route = resolveEnding(model, a.snapshot().stats,
        bonds: a.snapshot().bonds,
        milestones: a.snapshot().milestones,
        flags: a.snapshot().flags);
    expect(route['companionChoiceRoute'], 'open');
    expect(
        route['routeId'], contains('companion-choice:lumi-first-margin:open'));

    final left = run(), right = run();
    left.recordCompanionScene('lumi-first-margin', choiceIndex: 0);
    right.recordCompanionScene('lumi-first-margin', choiceIndex: 1);
    expect(left.snapshot().stats, isNot(equals(right.snapshot().stats)));
    expect(left.snapshot().flags, isNot(equals(right.snapshot().flags)));
    expect(left.snapshot().history, isNot(equals(right.snapshot().history)));
    final leftRoute = resolveEnding(model, left.snapshot().stats,
        bonds: left.snapshot().bonds,
        milestones: left.snapshot().milestones,
        flags: left.snapshot().flags);
    final rightRoute = resolveEnding(model, right.snapshot().stats,
        bonds: right.snapshot().bonds,
        milestones: right.snapshot().milestones,
        flags: right.snapshot().flags);
    expect(leftRoute['routeId'], isNot(equals(rightRoute['routeId'])));
  });
}
