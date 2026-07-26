import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

String sha(String path) => sha256.convert(File(path).readAsBytesSync()).toString();
String render(Map<String, dynamic> s, String hash) {
  final people = (s['personalities'] as List).cast<Map<String, dynamic>>();
  final acts = (s['activities'] as List).cast<Map<String, dynamic>>();
  final events = (s['events'] as List).cast<Map<String, dynamic>>();
  final b = StringBuffer('<!-- generated: tool/generate_ssot_docs.dart -->\n<!-- ssot-sha256: $hash -->\n<!-- source-ref: story/story.json#root -->\n\n# ${s['title']} · 스토리 SSOT\n\n');
  b.writeln('${s['setting']}에서 ${s['hero']}는 ${s['endingWeek']}주 동안 스스로 선택한 내일을 걷는다.');
  b.writeln('\n## 성격\n');
  for (final p in people) b.writeln('- **${p['name']}** (`${p['id']}`): ${p['voice']} “${p['line']}”');
  b.writeln('\n## 활동\n');
  for (final a in acts) b.writeln('- **${a['label']}** (`${a['id']}`): ${a['stat']} +${a['delta']} · ${a['hint']}');
  b.writeln('\n## 사건\n');
  for (final e in events) { b.writeln('### ${e['week']}주차 · ${e['title']}\n\n${e['body']}'); for (final c in (e['choices'] as List)) b.writeln('- ${c['label']}: ${c['stat']} +${c['delta']}, 은화 ${c['coins']} · “${c['line']}”'); }
  return b.toString();
}
void main(List<String> args) {
  final input = 'story/story.json', output = 'docs/story-ssot.md', hash = sha(input), expected = render(jsonDecode(File(input).readAsStringSync()), hash);
  if (args.contains('--check')) { if (!File(output).existsSync() || File(output).readAsStringSync() != expected) { stderr.writeln('SSOT_DOC_FAIL: regenerate $output'); exit(1); } stdout.writeln('SSOT_DOC_OK: $output sha256=$hash'); return; }
  File(output).writeAsStringSync(expected); stdout.writeln('SSOT_DOC_WRITTEN: $output sha256=$hash');
}
