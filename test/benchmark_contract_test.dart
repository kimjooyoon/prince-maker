import 'package:flutter_test/flutter_test.dart';

import '../tool/benchmark_game.dart' as benchmark;

void main() {
  test('replay set equality rejects same-cardinality outcome drift', () {
    expect(benchmark.sameSet({'ending-a', 'ending-b'},
        {'ending-a', 'ending-c'}), isFalse);
    expect(benchmark.sameSet({'ending-a', 'ending-b'},
        {'ending-b', 'ending-a'}), isTrue);
  });

  test('lineage replay equality compares keys and member outcomes', () {
    final first = <String, Set<String>>{
      'stargazer': {'stargazer-master'},
      'gardener': {'gardener-master'},
    };
    expect(benchmark.sameSetMap(first, {
      'stargazer': {'stargazer-master'},
      'gardener': {'gardener-master'},
    }), isTrue);
    expect(benchmark.sameSetMap(first, {
      'stargazer': {'stargazer-master'},
      'gardener': {'pathfinder-master'},
    }), isFalse);
  });
}
