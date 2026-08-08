import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/jsonl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('story JSONL is canonical and reconstructs authored collections',
      () async {
    final raw = utf8.decode(
        (await rootBundle.load('story/story.jsonl')).buffer.asUint8List());
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
    final raw = utf8.decode(
        (await rootBundle.load('story/locales/ko.jsonl')).buffer.asUint8List());
    final catalog = decodeJsonlCatalog(raw);
    expect(raw.split('\n').first, contains('lumen-locale-jsonl-v1'));
    expect(catalog.length, 1060);
    expect(catalog['ui.relationship.followup.estranged.title'], '늦은 답장');
    expect(catalog['ui.characterArt.title'], '루멘 사람들');
    expect(encodeJsonlCatalog(catalog, locale: 'ko'), raw);
  });
}
