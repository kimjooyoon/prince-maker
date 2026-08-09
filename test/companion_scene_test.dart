import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/companion_scene_archive_painter.dart';
import 'package:prince_maker/companion_scene_layout.dart';
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

  test('companion choice is recalled by the next authored scene', () async {
    final source = await loadStory(), model = JsonStoryAdapter(source);
    Map<String, bool> flagsFor(String choiceFlag) => {
          'companion-scene:lumi-first-margin': true,
          choiceFlag: true,
        };

    final open = resolveCompanionScenes(model, {'lumi': 2},
            flagsFor('companion-choice:lumi-first-margin:open'),
            currentChapter: 3)
        .firstWhere((scene) => scene['id'] == 'lumi-slow-star');
    final sealed = resolveCompanionScenes(model, {'lumi': 1},
            flagsFor('companion-choice:lumi-first-margin:sealed'),
            currentChapter: 3)
        .firstWhere((scene) => scene['id'] == 'lumi-slow-star');

    expect(open['available'], true);
    expect((open['choiceEcho'] as Map)['choiceId'], 'leave-open');
    expect((open['choiceEcho'] as Map)['responseKey'],
        'companionSceneChoice.lumi-first-margin.leave-open.response');
    expect((sealed['choiceEcho'] as Map)['choiceId'], 'seal-now');
    expect((sealed['choiceEcho'] as Map)['choiceId'],
        isNot((open['choiceEcho'] as Map)['choiceId']));
  });

  test('companion archive paint and tap geometry share one logical contract',
      () {
    for (var index = 0; index < CompanionSceneLayout.maxVisibleCards; index++) {
      final card = CompanionSceneLayout.cardRect(index);
      expect(CompanionSceneLayout.cardIndexAt(card.center, 6), index);
      for (var choice = 0; choice < 2; choice++) {
        final button = CompanionSceneLayout.choiceRect(index, choice);
        final hit = CompanionSceneLayout.choiceHitRect(index, choice);
        expect(card.contains(button.center), isTrue);
        expect(hit.contains(button.center), isTrue);
        expect(CompanionSceneLayout.choiceIndexAt(hit.center, index), choice);
      }
    }
    expect(
        CompanionSceneLayout.cardIndexAt(const ui.Offset(372, 250), 6), isNull,
        reason: 'the column gap must not activate an adjacent card');
    expect(
        CompanionSceneLayout.previousRect
            .overlaps(CompanionSceneLayout.nextRect),
        isFalse);
    expect(
        CompanionSceneLayout.backRect
            .overlaps(CompanionSceneLayout.previousRect),
        isFalse);
    expect(
        CompanionSceneLayout.backRect.overlaps(CompanionSceneLayout.nextRect),
        isFalse);
    expect(
        CompanionSceneLayout.containsInclusive(
            CompanionSceneLayout.nextHitRect, const ui.Offset(672, 700)),
        isTrue);
    expect(
        CompanionSceneLayout.containsInclusive(
            CompanionSceneLayout.backRect, const ui.Offset(80, 700)),
        isTrue);
  });

  test('companion archive canvas projection stays within the frame budget',
      () async {
    final source = await loadStory();
    final painter = CompanionSceneArchivePainter(
      story: source,
      bonds: const {'lumi': 1, 'bora': 1, 'taro': 1},
      flags: const {},
      portraitSheet: null,
      persona: 0,
      companionIndex: 0,
      currentChapter: 16,
      pendingSceneId: null,
      lastResult: '',
    );
    const iterations = 250;
    final watch = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      final recorder = ui.PictureRecorder();
      painter.paint(ui.Canvas(recorder));
      recorder.endRecording().dispose();
    }
    watch.stop();
    final averageMicros = watch.elapsedMicroseconds / iterations;
    stdout.writeln(
        'COMPANION_RENDER_PERF_OK: iterations=$iterations elapsedMillis=${watch.elapsedMilliseconds} averageMicros=${averageMicros.toStringAsFixed(1)}');
    expect(averageMicros, lessThan(8000),
        reason:
            'page 13 Canvas projection should remain below half a 60fps frame');
  });
}
