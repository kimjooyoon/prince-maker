import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/jsonl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('image design matrix closes the requested 288-frame formula', () async {
    final raw = utf8.decode(
        (await rootBundle.load('design/image-design-matrix.jsonl'))
            .buffer
            .asUint8List());
    final matrix = decodeJsonl(raw);
    final characterSheets =
        (matrix['characterEmotionSheets'] as List).cast<Map>();
    final eventSheets = (matrix['eventIllustrationSheets'] as List).cast<Map>();
    expect(characterSheets, hasLength(20));
    expect(eventSheets, hasLength(47));
    expect(
        characterSheets.fold<int>(
            0, (sum, row) => sum + (row['frameCount'] as int)),
        100);
    expect(
        eventSheets.fold<int>(
            0, (sum, row) => sum + (row['frameCount'] as int)),
        188);
    expect(matrix['totalFrameCount'], 288);
    expect(matrix['formula'], '5 * 20 + 4 * 47 = 288');
    expect(
        eventSheets.every((row) =>
            (row['majorCharacterIds'] as List).join(',') ==
            'noa,lumi,bora,taro'),
        isTrue);
    for (final row in [...characterSheets, ...eventSheets]) {
      final asset = '${row['asset']}';
      final bytes = (await rootBundle.load(asset)).buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      expect(frame.image.width, greaterThan(1500), reason: asset);
      expect(frame.image.height, greaterThan(700), reason: asset);
      expect(frame.image.width / frame.image.height, closeTo(2.4, .2),
          reason: asset);
    }
  });

  test('story binds all main events to their illustration sheets', () async {
    final story = decodeJsonl(utf8.decode(
        (await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));
    final events = (story['events'] as List).cast<Map>();
    expect(events, hasLength(47));
    expect(
        events.every((event) => '${event['illustrationAsset']}'
            .startsWith('assets/generated/event-illustrations/event-')),
        isTrue);
    expect(events.map((event) => event['illustrationAsset']).toSet(),
        hasLength(47));
  });
}
