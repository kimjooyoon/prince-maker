import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:prince_maker/jsonl.dart';

Never fail(String message) {
  stderr.writeln('DECISION_PROOF_GATE_FAIL: $message');
  exit(1);
}

Map<String, dynamic> json(String path) =>
    decodeJsonl(File(path).readAsStringSync());

String sha(String path) =>
    sha256.convert(File(path).readAsBytesSync()).toString();

void main() {
  const contractPath = 'docs/decision-proof-contract.jsonl';
  final contract = json(contractPath), story = json('story/story.jsonl');
  if (contract['schema'] != 'lumen-decision-proof-v1' ||
      contract['version'] != 1) fail('contract schema/version drift');
  final source = (contract['source'] as Map).cast<String, dynamic>();
  if (source['ref'] != 'story/story.jsonl#decisionSystem' ||
      source['sha256'] != sha('story/story.jsonl')) {
    fail('decision proof contract is detached from story SSOT');
  }
  final fields = (contract['preconditionFields'] as List).cast<String>();
  const required = [
    'kind',
    'subject',
    'week',
    'endingWeek',
    'coins',
    'fatigue',
    'selected',
    'persona',
    'eventIndex',
    'stats',
    'bonds',
    'milestones',
    'flags',
    'conditions'
  ];
  if (fields.length != required.length ||
      fields.toSet().difference(required.toSet()).isNotEmpty) {
    fail('precondition field contract is incomplete');
  }
  final chain = (contract['chain'] as Map).cast<String, dynamic>();
  if (chain['root'] != 'genesis' ||
      chain['parentField'] != 'parentDecisionHash' ||
      chain['decisionField'] != 'decisionHash' ||
      chain['replayMustMatch'] != true) {
    fail('decision chain must be rooted and replayable');
  }
  final decision = (story['decisionSystem'] as Map).cast<String, dynamic>();
  final policy = (contract['decision'] as Map).cast<String, dynamic>();
  if (decision['mode'] != policy['mode'] ||
      decision['humanApprovalRequired'] != policy['humanApprovalRequired'] ||
      decision['failureMode'] != policy['failureMode']) {
    fail('story decision system does not satisfy proof policy');
  }
  final sourceChecks = {
    'lib/decision_proof.dart': [
      'class SystemDecisionPolicy',
      'preconditionHash',
      'parentDecisionHash',
      'static String digest'
    ],
    'lib/game_core.dart': [
      '_preconditionState',
      'SystemDecisionPolicy.parentHash'
    ],
    'lib/decision_receipt.dart': ['shortPreconditionHash'],
    'test/decision_proof_test.dart': [
      'same preconditions reproduce the same chain'
    ]
  };
  for (final entry in sourceChecks.entries) {
    final text = File(entry.key).readAsStringSync();
    for (final phrase in entry.value) {
      if (!text.contains(phrase))
        fail('${entry.key} missing proof phrase $phrase');
    }
  }
  final verdict = {
    'schema': 'lumen-decision-proof-verdict-v1',
    'decision': 'approve',
    'source': source,
    'preconditionFields': fields.length,
    'chain': chain,
    'proofs': sourceChecks.keys.toList()
  };
  final out = File('build/decision-proof-verdict.json')
    ..parent.createSync(recursive: true);
  out.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(verdict)}\n');
  stdout.writeln(
      'DECISION_PROOF_PRECONDITIONS_OK: fields=${fields.length} chain=rooted-replayable');
}
