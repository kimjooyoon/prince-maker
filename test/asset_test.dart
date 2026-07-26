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
}
