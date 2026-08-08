import 'dart:convert';
import 'dart:io';

import 'package:prince_maker/jsonl.dart';

const files = [
  'story/story.jsonl',
  'story/locales/ko.jsonl',
  'story/locales/en.jsonl',
  'design/tokens.jsonl',
  'docs/decision-proof-contract.jsonl',
  'docs/development-goals.jsonl',
  'docs/originality-contract.jsonl',
  'docs/render-quality-contract.jsonl',
  'docs/review-manifest.jsonl',
  'docs/trilemma-contract.jsonl',
];

String target(String path) => path.replaceFirst(RegExp(r'\.json$'), '.jsonl');

String schema(String path) => path.startsWith('story/locales/')
    ? 'lumen-locale-jsonl-v1'
    : path == 'story/story.jsonl'
        ? 'lumen-story-ssot-jsonl-v1'
        : 'lumen-document-jsonl-v1';

void main() {
  for (final path in files) {
    final source = File(path);
    final raw = source.readAsStringSync();
    final root = raw.trimLeft().startsWith('{"type":"header"')
        ? decodeJsonl(raw)
        : (jsonDecode(raw) as Map).map((key, value) => MapEntry('$key', value));
    final map = root.map((key, value) => MapEntry('$key', value));
    final output = path.startsWith('story/locales/')
        ? encodeJsonlCatalog(
            map.map((key, value) => MapEntry(key, '$value')),
            locale: path.split('/').last.split('.').first,
          )
        : encodeJsonl(map, schema: schema(path), document: path);
    File(target(path)).writeAsStringSync(output);
    stdout.writeln(
        'JSONL_MIGRATED: $path -> ${target(path)} lines=${output.split('\n').length - 1}');
  }
}
