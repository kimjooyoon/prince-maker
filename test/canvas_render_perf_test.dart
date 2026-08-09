import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/activity_catalog.dart';
import 'package:prince_maker/jsonl.dart';
import 'package:prince_maker/main.dart';

Future<Map<String, dynamic>> loadStory() async => decodeJsonl(utf8
    .decode((await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));

Future<Map<String, Map<String, String>>> loadLocales() async => {
      for (final locale in ['ko', 'en'])
        locale: decodeJsonlCatalog(utf8.decode(
            (await rootBundle.load('story/locales/$locale.jsonl'))
                .buffer
                .asUint8List()))
    };

Scene scene(Map<String, dynamic> story,
        Map<String, Map<String, String>> locales, int page) =>
    Scene(
      story,
      page == 2 ? story['endingWeek'] as int : 8,
      12,
      2,
      0,
      {'지혜': 8, '공감': 7, '용기': 6},
      {'lumi': 2, 'bora': 1, 'taro': 1},
      {},
      {},
      '',
      '',
      page,
      0,
      null,
      null,
      null,
      {},
      {},
      {},
      const ['activity:지혜+3', 'event:별의 이름을 묻는다'],
      0,
      0,
      0,
      0,
      'perf-snapshot',
      activitiesFromStory(story),
      const [],
      null,
      null,
      0,
      null,
      'ko',
      locales,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('full Canvas pages stay within the deterministic frame budget',
      () async {
    final story = await loadStory(), locales = await loadLocales();
    const pages = [0, 3, 2, 5, 11, 13], iterations = 24;
    final contentBudget =
        (story['contentBudget'] as Map).cast<String, dynamic>();
    final pageBudget = contentBudget['canvasPaintBudgetMicros'] as int;
    final declaredPages = (contentBudget['canvasRenderPages'] as List).length;
    expect(declaredPages, pages.length);
    final painters = pages.map((page) => scene(story, locales, page)).toList();
    for (final painter in painters) {
      final recorder = ui.PictureRecorder();
      painter.paint(ui.Canvas(recorder), const ui.Size(760, 700));
      recorder.endRecording().dispose();
    }
    final watch = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      for (final painter in painters) {
        final recorder = ui.PictureRecorder();
        painter.paint(ui.Canvas(recorder), const ui.Size(760, 700));
        recorder.endRecording().dispose();
      }
    }
    watch.stop();
    final averageMicros =
        watch.elapsedMicroseconds / (iterations * pages.length);
    stdout.writeln('CANVAS_RENDER_PERF_OK: pages=${pages.length} '
        'iterations=$iterations elapsedMillis=${watch.elapsedMilliseconds} '
        'averageMicros=${averageMicros.toStringAsFixed(1)}');
    expect(averageMicros, lessThan(pageBudget));
  });
}
