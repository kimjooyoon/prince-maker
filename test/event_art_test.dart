import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/event_art.dart';
import 'package:prince_maker/jsonl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every main event has a deterministic illustration asset', () async {
    final story = decodeJsonl(utf8.decode(
        (await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));
    final events = (story['events'] as List).cast<Map<String, dynamic>>();
    expect(events, hasLength(47));
    final assets = <String>{};
    for (final event in events) {
      final asset = eventIllustrationAsset(event);
      expect(asset,
          'assets/generated/event-illustrations/event-${event['week']}.png');
      expect(assets.add(asset), isTrue);
      final bytes = (await rootBundle.load(asset)).buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      expect(frame.image.width, greaterThan(1500));
      expect(frame.image.height, greaterThan(700));
      expect(frame.image.width / frame.image.height, closeTo(2.4, .2));
    }
    expect(assets, hasLength(47));
  });
}
