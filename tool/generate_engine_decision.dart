import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:prince_maker/jsonl.dart';

String sha(String path) =>
    sha256.convert(File(path).readAsBytesSync()).toString();

Map<String, dynamic> source() => decodeJsonl(
      File('story/story.jsonl').readAsStringSync(),
    );

String markdown(Map<String, dynamic> story, String hash) {
  final decision = (story['engineDecision'] as Map).cast<String, dynamic>();
  final criteria = (decision['criteria'] as List).cast<Map>();
  final options = (decision['options'] as List).cast<Map>();
  final b =
      StringBuffer('''<!-- generated: tool/generate_engine_decision.dart -->
<!-- ssot-sha256: $hash -->
<!-- source-ref: story/story.jsonl#engineDecision -->

# 렌더러 결정 계약

선택: **`${decision['selectedOption']}`** · 규칙: `${decision['decisionRule']}`

점수는 측정된 런타임 성능이 아니라, 이 게임의 Canvas·Golden·WASM·콘텐츠 루프에 대한 정규화된 아키텍처 적합도다. 실제 성능은 [`benchmark_game.dart`](../tool/benchmark_game.dart)가 판정한다.

| 기준 | 가중치 | 판정 질문 |
| --- | ---: | --- |
''');
  for (final criterion in criteria) {
    b.writeln(
        '| `${criterion['id']}` | ${criterion['weight']} | ${criterion['question']} |');
  }
  b.writeln('\n| 선택지 | 적합도 | 결정 상태 |\n| --- | ---: | --- |');
  for (final option in options) {
    final status = option['id'] == decision['selectedOption']
        ? 'selected'
        : 'recorded alternative';
    b.writeln(
        '| `${option['id']}` | ${option['architecturalFitScore']} | $status |');
  }
  b.writeln('\n## 증거\n');
  for (final option in options) {
    b.writeln('### `${option['id']}`');
    for (final evidence in (option['evidence'] as List).cast<Map>()) {
      final ref = '${evidence['ref']}';
      b.writeln(
          '- [${evidence['claim']}](${ref.startsWith('http') ? ref : '../$ref'})');
    }
  }
  b.writeln('\n## 재검토 조건\n');
  for (final constraint in (decision['constraints'] as List))
    b.writeln('- $constraint');
  return b.toString();
}

void main(List<String> args) {
  const input = 'story/story.jsonl';
  final story = source(),
      hash = sha(input),
      decision = (story['engineDecision'] as Map).cast<String, dynamic>(),
      jsonl = encodeJsonl({
        'source': {'ref': '$input#engineDecision', 'sha256': hash},
        ...decision,
      },
          schema: 'lumen-document-jsonl-v1',
          document: 'docs/engine-decision.jsonl'),
      outputs = {
        'docs/engine-decision.jsonl': jsonl,
        'docs/engine-decision.md': markdown(story, hash),
      };
  if (args.contains('--check')) {
    for (final entry in outputs.entries) {
      if (!File(entry.key).existsSync() ||
          File(entry.key).readAsStringSync() != entry.value) {
        stderr.writeln('ENGINE_DECISION_FAIL: regenerate ${entry.key}');
        exit(1);
      }
    }
    stdout.writeln('ENGINE_DECISION_OK: ${outputs.keys.join(', ')}');
    return;
  }
  for (final entry in outputs.entries)
    File(entry.key).writeAsStringSync(entry.value);
  stdout.writeln('ENGINE_DECISION_WRITTEN: ${outputs.keys.join(', ')}');
}
