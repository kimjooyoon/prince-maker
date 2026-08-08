import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/jsonl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every side scene binds a deterministic illustration frame', () async {
    final story = decodeJsonl(utf8.decode(
        (await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));
    final scenes = (story['sideScenes'] as List).cast<Map>();
    final frames = <String, Set<int>>{};
    for (final scene in scenes) {
      final asset = '${scene['illustrationAsset']}',
          frame = scene['illustrationFrame'];
      expect(asset, startsWith('assets/generated/side-scene-illustrations/'));
      expect(frame, isA<int>());
      expect(frame, inInclusiveRange(0, 3));
      (frames[asset] ??= <int>{}).add(frame as int);
    }
    expect(scenes, hasLength(24));
    expect(frames, hasLength(6));
    expect(frames.values.every((value) => value.length == 4), isTrue);
    for (final asset in frames.keys) {
      final bytes = (await rootBundle.load(asset)).buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(bytes);
      final image = (await codec.getNextFrame()).image;
      expect(image.width, greaterThan(1500), reason: asset);
      expect(image.height, greaterThan(700), reason: asset);
      expect(image.width / image.height, closeTo(2.0, .1), reason: asset);
    }
  });
}
