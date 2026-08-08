import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/jsonl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('story JSONL is canonical and reconstructs authored collections',
      () async {
    final raw = await rootBundle.loadString('story/story.jsonl');
    final story = decodeJsonl(raw);
    expect(raw.split('\n').first, contains('lumen-story-ssot-jsonl-v1'));
    expect(story['events'], hasLength(47));
    expect(story['events'].first['week'], 2);
    expect(
        encodeJsonl(story,
            schema: 'lumen-story-ssot-jsonl-v1', document: 'story/story.jsonl'),
        raw);
  });

  test('locale JSONL keeps one changed key per reviewable entry', () async {
    final raw = await rootBundle.loadString('story/locales/ko.jsonl');
    final catalog = decodeJsonlCatalog(raw);
    expect(raw.split('\n').first, contains('lumen-locale-jsonl-v1'));
    expect(catalog.length, 513);
    expect(catalog['ui.relationship.followup.estranged.title'], '늦은 답장');
    expect(encodeJsonlCatalog(catalog, locale: 'ko'), raw);
  });
}
