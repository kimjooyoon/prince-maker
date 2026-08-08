import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/canvas_scene_fingerprint.dart';

void main() {
  test('normalizes map insertion order for deterministic repaint keys', () {
    final first = canvasSceneFingerprint([
      {
        'bonds': {'bora': 2, 'lumi': 4},
        'week': 8
      },
      ['quiet', 3, true],
    ]);
    final second = canvasSceneFingerprint([
      {
        'week': 8,
        'bonds': {'lumi': 4, 'bora': 2}
      },
      ['quiet', 3, true],
    ]);

    expect(first, second);
  });

  test('changes when a rendered state value changes', () {
    expect(
        canvasSceneFingerprint([
          8,
          {'selected': 1}
        ]),
        isNot(canvasSceneFingerprint([
          8,
          {'selected': 2}
        ])));
  });
}
