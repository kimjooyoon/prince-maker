import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('personality PNG is loadable as a three-frame sheet', () async {
    final bytes = await rootBundle.load('assets/lumen-personality-sheet.png');
    final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    expect(frame.image.width / frame.image.height, closeTo(3, .05));
    expect(frame.image.width, greaterThan(1000));
  });
  test('Noa PNG is loadable as a three-frame two-head hero sheet', () async {
    final bytes = await rootBundle.load('assets/noa-sprite-sheet.png');
    final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    expect(frame.image.width, greaterThan(1600));
    expect(frame.image.height, greaterThan(500));
  });
  test('bundled Korean font is loadable for deterministic Canvas text',
      () async {
    final bytes = await rootBundle.load('assets/fonts/NotoSansKR-Regular.ttf');
    expect(bytes.lengthInBytes, greaterThan(100000));
  });
  test('SSOT maps three original personality designs to unique PNG frames',
      () async {
    final source = jsonDecode(utf8.decode(
            (await rootBundle.load('story/story.json')).buffer.asUint8List()))
        as Map<String, dynamic>;
    final people =
        (source['personalities'] as List).cast<Map<String, dynamic>>();
    expect(people.length, 3);
    expect(people.map((p) => p['portraitAsset']).toSet(),
        {'assets/lumen-personality-sheet.png'});
    expect(people.map((p) => p['portraitFrame']).toSet(), {0, 1, 2});
    expect(people.every((p) {
      final design = p['design'] as Map<String, dynamic>;
      return design['palette'] is String &&
          design['motif'] is String &&
          design['silhouette'] is String;
    }), isTrue);
  });
}
