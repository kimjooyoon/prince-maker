import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/jsonl.dart';

void main() {
  test('deterministic Flutter Canvas engine selection', () {
    final story = decodeJsonl(File('story/story.jsonl').readAsStringSync()),
        decision = (story['engineDecision'] as Map).cast<String, dynamic>(),
        criteria = (decision['criteria'] as List).cast<Map<String, dynamic>>(),
        options = (decision['options'] as List).cast<Map<String, dynamic>>(),
        ids = criteria.map((criterion) => criterion['id'] as String).toSet();
    expect(decision['selectedOption'], 'flutter-canvas-wasm');
    expect(
        criteria.fold<double>(0, (sum, c) => sum + (c['weight'] as num)), 1.0);
    expect(ids.length, criteria.length);
    final scores = <String, double>{};
    for (final option in options) {
      final values = (option['scores'] as Map).cast<String, dynamic>();
      expect(values.keys.toSet(), ids);
      final score = criteria.fold<double>(
          0, (sum, c) => sum + (c['weight'] as num) * (values[c['id']] as num));
      expect(score, closeTo(option['architecturalFitScore'] as num, 0.00001));
      scores[option['id'] as String] = score;
      expect((option['evidence'] as List), isNotEmpty);
    }
    expect(scores['flutter-canvas-wasm'],
        scores.values.reduce((a, b) => a > b ? a : b));
    expect(decision['scoreMeaning'],
        contains('not a claim of measured engine throughput'));
  });
}
