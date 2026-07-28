import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/collection_adapter.dart';

void main() {
  test('ending collection keeps the best deterministic rank per ending', () {
    final collection = MemoryCollectionAdapter();
    collection.record('gardener-master', 1);
    collection.record('gardener-master', 3);
    collection.record('stargazer-master', 2);
    expect(collection.read(), [
      {'id': 'gardener-master', 'rank': 3},
      {'id': 'stargazer-master', 'rank': 2},
    ]);
  });
  test('ending collection accumulates deterministic relationship routes', () {
    final collection = MemoryCollectionAdapter();
    collection.record('gardener-master', 2, routes: ['bora']);
    collection.record('gardener-master', 3, routes: ['lumi', 'bora']);
    expect(collection.read().single, {
      'id': 'gardener-master',
      'rank': 3,
      'routes': ['bora', 'lumi']
    });
  });
}
