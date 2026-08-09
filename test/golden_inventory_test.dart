import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Golden inventory and player-facing evidence stay synchronized', () {
    final count = Directory('test/goldens')
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.png'))
        .length;
    final readme = File('README.md').readAsStringSync();
    final completeness = File('docs/game-completeness.md').readAsStringSync();
    final scenario = File('docs/scenario-completeness.md').readAsStringSync();
    expect(count, greaterThan(0));
    expect(readme, contains('전체 Canvas Golden 증적은 ${count}장'));
    expect(completeness, contains('Golden | $count |'));
    expect(scenario, contains('$count Golden,'));
  });
}
