import 'dart:io';

import 'package:prince_maker/jsonl.dart';

Never fail(String message) {
  stderr.writeln('JSONL_GATE_FAIL: $message');
  exit(1);
}

String expectedSchema(String path) => path.startsWith('story/locales/')
    ? 'lumen-locale-jsonl-v1'
    : path == 'story/story.jsonl'
        ? 'lumen-story-ssot-jsonl-v1'
        : 'lumen-document-jsonl-v1';

String canonical(String path, String raw) {
  final lines = raw.split('\n');
  if (lines.length < 2 || lines.last != '')
    fail('$path must end with one newline');
  if (lines.take(lines.length - 1).any((line) => line.trim().isEmpty))
    fail('$path contains a blank JSONL line');
  final header = lines.first;
  if (!header.contains('"type":"header"') ||
      !header.contains('"schema":"${expectedSchema(path)}"')) {
    fail('$path header schema drift');
  }
  return path.startsWith('story/locales/')
      ? encodeJsonlCatalog(decodeJsonlCatalog(raw),
          locale: path.split('/').last.split('.').first)
      : encodeJsonl(decodeJsonl(raw),
          schema: expectedSchema(path), document: path);
}

void main() {
  final roots = [Directory('story'), Directory('docs'), Directory('design')];
  final files = roots
      .expand((root) => root.listSync(recursive: true))
      .whereType<File>()
      .where((file) => file.path.endsWith('.jsonl'))
      .map((file) => file.path)
      .toList()
    ..sort();
  if (files.isEmpty) fail('no JSONL SSOT files found');
  for (final path in files) {
    final file = File(path), raw = file.readAsStringSync();
    if (canonical(path, raw) != raw) fail('$path is not canonical JSONL');
  }
  for (final root in roots) {
    if (!root.existsSync()) continue;
    final legacy = root
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'));
    if (legacy.isNotEmpty) fail('legacy JSON remains under ${root.path}');
  }
  stdout.writeln(
      'JSONL_GATE_OK: files=${files.length} canonical=true legacy-json=false');
}
