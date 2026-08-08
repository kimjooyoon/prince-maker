import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

Never fail(String message) {
  stderr.writeln('CI_POLICY_FAIL: $message');
  exit(1);
}

String sha256File(String path) =>
    sha256.convert(File(path).readAsBytesSync()).toString();

void requireFile(String path) {
  if (!File(path).existsSync()) fail('missing required policy file $path');
}

void main() {
  const workflowPath = '.github/workflows/verify.yml';
  const hookPath = '.githooks/pre-commit';
  const policyPath = 'docs/automation-policy.md';
  const originalityPath = 'docs/originality-contract.json';
  for (final path in [workflowPath, hookPath, policyPath, originalityPath]) {
    requireFile(path);
  }

  final workflow = File(workflowPath).readAsStringSync();
  final hook = File(hookPath).readAsStringSync();
  final policy = File(policyPath).readAsStringSync();
  final story = jsonDecode(File('story/story.json').readAsStringSync())
      as Map<String, dynamic>;
  final decision =
      (story['decisionSystem'] as Map? ?? {}).cast<String, dynamic>();
  if (!workflow.contains('pull_request:') ||
      !workflow.contains('push:') ||
      !workflow.contains('workflow_dispatch:') ||
      !workflow.contains('permissions:') ||
      !workflow.contains('contents: read') ||
      !workflow.contains('concurrency:') ||
      !workflow.contains('cancel-in-progress: true') ||
      !workflow.contains('system-approval:') ||
      !workflow.contains('dart run tool/ci_gate.dart --ci') ||
      workflow.contains('pull_request_target') ||
      workflow.contains('continue-on-error: true')) {
    fail('workflow must expose a read-only, fail-closed system approval job');
  }
  if (!hook.contains('dart run tool/ci_gate.dart --local') ||
      hook.contains('|| true') ||
      hook.contains('continue-on-error')) {
    fail('pre-commit must delegate to the fail-closed system gate');
  }
  if (decision['mode'] != 'system-adjudicated' ||
      decision['humanApprovalRequired'] != false ||
      decision['failureMode'] != 'fail-closed' ||
      !File('lib/game_core.dart')
          .readAsStringSync()
          .contains('class SystemDecisionPolicy')) {
    fail('story and runtime must declare system-owned fail-closed adjudication');
  }
  for (final phrase in [
    'SYSTEM_APPROVAL: APPROVE',
    'required status check',
    '사람의 승인',
    'ci-verdict.json'
  ]) {
    if (!policy.contains(phrase))
      fail('automation policy is missing "$phrase"');
  }

  final contract = jsonDecode(File(originalityPath).readAsStringSync())
      as Map<String, dynamic>;
  if (contract['schema'] != 'lumen-originality-v1') {
    fail('unsupported originality contract schema');
  }
  final source = (contract['source'] as Map).cast<String, dynamic>();
  if (source['ref'] != 'story/story.json#root' ||
      source['sha256'] != sha256File('story/story.json')) {
    fail('originality contract is detached from story/story.json');
  }
  final pillars =
      (contract['pillars'] as List? ?? const []).cast<Map<String, dynamic>>();
  if (pillars.length < 4 ||
      pillars.any((pillar) =>
          '${pillar['id']}'.trim().isEmpty ||
          '${pillar['rule']}'.trim().isEmpty ||
          '${pillar['difference']}'.trim().isEmpty ||
          (pillar['evidence'] as List? ?? const []).length < 2)) {
    fail(
        'each originality pillar needs a rule, difference and two evidence refs');
  }
  final references = (contract['referencePrinciples'] as List? ?? const [])
      .cast<Map<String, dynamic>>();
  if (references.length < 3 ||
      references.any((reference) =>
          '${reference['id']}'.trim().isEmpty ||
          (reference['sources'] as List? ?? const []).isEmpty ||
          '${reference['observed']}'.trim().isEmpty ||
          '${reference['adoptedAs']}'.trim().isEmpty)) {
    fail('external references must be recorded as mechanic-level principles');
  }
  final antiCopying = (contract['antiCopyingRules'] as List? ?? const [])
      .whereType<String>()
      .where((rule) => rule.trim().isNotEmpty)
      .length;
  if (antiCopying < 4) fail('originality contract needs anti-copying rules');
  stdout.writeln(
      'CI_POLICY_OK: system approval + originality contract · pillars=${pillars.length} references=${references.length}');
}
