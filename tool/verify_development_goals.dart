import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:prince_maker/jsonl.dart';

import 'generate_development_goals.dart' as generator;

Never fail(String message) {
  stderr.writeln('DEVELOPMENT_GOALS_GATE_FAIL: $message');
  exit(1);
}

Map<String, dynamic> readJson(String path) {
  final file = File(path);
  if (!file.existsSync()) fail('missing $path');
  final raw = file.readAsStringSync();
  return path.endsWith('.jsonl')
      ? decodeJsonl(raw)
      : jsonDecode(raw) as Map<String, dynamic>;
}

String sha256File(String path) =>
    sha256.convert(File(path).readAsBytesSync()).toString();

void requireEqual(Object? actual, Object? expected, String message) {
  if (actual != expected) fail('$message · actual=$actual expected=$expected');
}

void main() {
  final expected = generator.buildDocument(),
      expectedJson = encodeJsonl(expected,
          schema: 'lumen-document-jsonl-v1',
          document: 'docs/development-goals.jsonl'),
      expectedMarkdown = generator.renderMarkdown(expected),
      jsonFile = File('docs/development-goals.jsonl'),
      markdownFile = File('docs/development-goals.md');
  if (!jsonFile.existsSync() || jsonFile.readAsStringSync() != expectedJson) {
    fail(
        'development-goals.json is stale or not generated from current sources');
  }
  if (!markdownFile.existsSync() ||
      markdownFile.readAsStringSync() != expectedMarkdown) {
    fail('development-goals.md is stale or not generated from current sources');
  }

  final document = readJson('docs/development-goals.jsonl');
  requireEqual(
      document['schema'], 'lumen-development-goals-v1', 'schema drift');
  requireEqual(document['version'], 1, 'version drift');
  final decision = (document['decision'] as Map).cast<String, dynamic>();
  if (decision['owner'] != 'Lumen Development Goal Gate' ||
      decision['mode'] != 'system-adjudicated' ||
      decision['humanApprovalRequired'] != false ||
      decision['failureMode'] != 'fail-closed' ||
      decision['onlyBlockingCondition'] !=
          'missing or failed quantitative evidence') {
    fail('goal decision must be system-owned and fail-closed');
  }
  final sources = (document['source'] as List).cast<Map<String, dynamic>>();
  for (final source in sources) {
    final ref = '${source['ref']}', path = ref.split('#').first;
    if (!File(path).existsSync()) fail('missing source for $ref');
    requireEqual(
        source['sha256'], sha256File(path), 'source hash drift for $ref');
  }
  final goals = (document['goals'] as List).cast<Map<String, dynamic>>();
  if (goals.length != 6 ||
      goals.map((goal) => goal['id']).toSet().length != goals.length) {
    fail('exactly six unique high-level goals are required');
  }
  final ledger =
      (document['effortLedger'] as List).cast<Map<String, dynamic>>();
  if (ledger.length != 5 ||
      ledger.any((row) =>
          '${row['id']}'.trim().isEmpty ||
          '${row['unit']}'.trim().isEmpty ||
          row['value'] is! int ||
          (row['value'] as int) <= 0 ||
          '${row['formula']}'.trim().isEmpty ||
          '${row['scope']}'.trim().isEmpty)) {
    fail('every effort ledger row needs a positive quantity and formula');
  }
  for (final goal in goals) {
    for (final key in [
      'target',
      'currentContract',
      'gap',
      'status',
      'effort',
      'preconditions',
      'evidence',
      'acceptance'
    ]) {
      if (!goal.containsKey(key)) fail('${goal['id']} missing $key');
    }
    if ((goal['effort'] as List).isEmpty ||
        (goal['preconditions'] as List).isEmpty ||
        (goal['evidence'] as List).isEmpty ||
        '${goal['acceptance']}'.trim().isEmpty) {
      fail(
          '${goal['id']} must have effort, preconditions, evidence and acceptance');
    }
  }

  final benchmark = readJson('build/benchmark-verdict.json');
  requireEqual(benchmark['schema'], 'lumen-campaign-benchmark-v1',
      'benchmark schema drift');
  requireEqual(benchmark['decision'], 'approve', 'benchmark did not approve');
  requireEqual(benchmark['campaigns'], 5000, 'campaign workload drift');
  requireEqual(benchmark['transitions'], 475000, 'transition workload drift');
  if ((benchmark['elapsedMillis'] as num) > 24000) {
    fail('benchmark exceeded 24,000ms: ${benchmark['elapsedMillis']}');
  }
  requireEqual(benchmark['checksum'], benchmark['replayChecksum'],
      'benchmark replay checksum drift');
  if ((benchmark['signatures'] as int) < 3 ||
      (benchmark['endings'] as int) < 3 ||
      (benchmark['locations'] as int) < 4) {
    fail('benchmark variety guardrail is below target');
  }

  final decisionProof = readJson('build/decision-proof-verdict.json');
  requireEqual(decisionProof['schema'], 'lumen-decision-proof-verdict-v1',
      'decision proof schema drift');
  requireEqual(decisionProof['decision'], 'approve',
      'decision proof preconditions did not approve');
  requireEqual(decisionProof['preconditionFields'], 14,
      'decision proof field budget drift');
  final chain = (decisionProof['chain'] as Map).cast<String, dynamic>();
  if (chain['root'] != 'genesis' ||
      chain['parentField'] != 'parentDecisionHash' ||
      chain['decisionField'] != 'decisionHash' ||
      chain['replayMustMatch'] != true) {
    fail('decision proof chain is not rooted and replayable');
  }

  final render = readJson('docs/render-quality-contract.jsonl'),
      renderPreconditions = (render['preconditions'] as List).length,
      renderProofs = (render['proofs'] as List).length,
      goalVerdict = {
        'schema': 'lumen-development-goal-verdict-v1',
        'source': {
          'ref': 'docs/development-goals.jsonl#goals',
          'sha256': sha256File('docs/development-goals.jsonl'),
        },
        'decision': 'approve',
        'goals': [
          for (final goal in goals)
            {
              'id': goal['id'],
              'status': 'pass',
              'preconditions': goal['preconditions'],
              'evidence': goal['evidence'],
            }
        ],
        'measuredEvidence': {
          'decisionProof': decisionProof,
          'benchmark': benchmark,
          'renderPreconditions': renderPreconditions,
          'renderProofs': renderProofs,
          'effortLedgerRows': ledger.length,
          'goalCount': goals.length,
        },
      };
  final out = File('build/development-goal-verdict.json')
    ..parent.createSync(recursive: true);
  out.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(goalVerdict)}\n');
  stdout.writeln(
      'DEVELOPMENT_GOALS_OK: goals=${goals.length} ledger=${ledger.length} benchmark=${benchmark['elapsedMillis']}ms renderPreconditions=$renderPreconditions renderProofs=$renderProofs');
}
