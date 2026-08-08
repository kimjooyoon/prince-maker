import 'dart:convert';
import 'dart:io';
import 'trilemma_verdict.dart';

class GateCheck {
  const GateCheck(this.id, this.executable, this.arguments);

  final String id;
  final String executable;
  final List<String> arguments;
}

Future<int> runCheck(GateCheck check) async {
  stdout.writeln('SYSTEM_GATE_START: ${check.id}');
  try {
    final result =
        await Process.run(check.executable, check.arguments, runInShell: true);
    final output = '${result.stdout}${result.stderr}';
    if (output.trim().isNotEmpty) stdout.write(output);
    final code = result.exitCode;
    stdout.writeln('SYSTEM_GATE_${code == 0 ? 'PASS' : 'FAIL'}: ${check.id}');
    return code;
  } on Object catch (error) {
    stderr.writeln('SYSTEM_GATE_FAIL: ${check.id} · $error');
    return 1;
  }
}

void writeVerdict(String mode, List<Map<String, dynamic>> checks,
    {required bool approved}) {
  final report = {
    'schema': 'lumen-system-approval-v1',
    'mode': mode,
    'decision': approved ? 'approve' : 'reject',
    'checks': checks,
  };
  final file = File('build/ci-verdict.json');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(report) + '\n');
}

Future<void> main(List<String> args) async {
  final mode = args.contains('--ci') ? 'ci' : 'local';
  final checks = <GateCheck>[
    const GateCheck(
        'jsonl-contract', 'dart', ['run', 'tool/verify_jsonl.dart']),
    const GateCheck('ci-policy', 'dart', ['run', 'tool/verify_ci_policy.dart']),
    const GateCheck('decision-proof-preconditions', 'dart',
        ['run', 'tool/verify_decision_proof.dart']),
    const GateCheck('render-quality-preconditions', 'dart',
        ['run', 'tool/verify_render_quality.dart']),
    const GateCheck('story-contract', 'dart', ['run', 'tool/verify_game.dart']),
    const GateCheck(
        'content-depth', 'dart', ['run', 'tool/verify_content_depth.dart']),
    const GateCheck(
        'event-storm', 'dart', ['run', 'tool/verify_event_storm.dart']),
    const GateCheck(
        'gameplay-fun', 'dart', ['run', 'tool/verify_gameplay_fun.dart']),
    const GateCheck('scenario-variants', 'dart',
        ['run', 'tool/verify_scenario_variants.dart']),
    const GateCheck(
        'campaign-benchmark', 'dart', ['run', 'tool/benchmark_game.dart']),
    const GateCheck(
        'quality-score', 'dart', ['run', 'tool/verify_quality_score.dart']),
    const GateCheck('generated-trilemma-contract', 'dart',
        ['run', 'tool/generate_trilemma_contract.dart', '--check']),
    const GateCheck('generated-ssot-docs', 'dart',
        ['run', 'tool/generate_ssot_docs.dart', '--check']),
    const GateCheck('generated-engine-decision', 'dart',
        ['run', 'tool/generate_engine_decision.dart', '--check']),
    const GateCheck('generated-event-storm', 'dart',
        ['run', 'tool/generate_event_storm.dart', '--check']),
    const GateCheck(
        'review-manifest', 'dart', ['run', 'tool/verify_review_manifest.dart']),
    const GateCheck('static-analysis', 'flutter', ['analyze']),
    const GateCheck('tests-and-goldens', 'flutter', ['test']),
    if (mode == 'ci')
      const GateCheck('wasm-release-build', 'flutter',
          ['build', 'web', '--wasm', '--release']),
    const GateCheck('diff-whitespace', 'git', ['diff', '--check']),
    const GateCheck('generated-development-goals', 'dart',
        ['run', 'tool/verify_development_goals.dart']),
  ];

  final results = <Map<String, dynamic>>[];
  var approved = true;
  for (final check in checks) {
    final exitCode = await runCheck(check);
    results.add({
      'id': check.id,
      'status': exitCode == 0 ? 'pass' : 'fail',
      'exitCode': exitCode,
    });
    if (exitCode != 0) {
      approved = false;
      break;
    }
  }
  writeVerdict(mode, results, approved: approved);
  final trilemma = writeTrilemmaVerdict(mode, results),
      trilemmaApproved = trilemma['decision'] == 'approve',
      receiptValid = verifyTrilemmaReceipt(trilemma),
      axes = (trilemma['axes'] as Map).cast<String, dynamic>();
  stdout.writeln('TRILEMMA_RECEIPT: ${receiptValid ? 'VALID' : 'INVALID'} · '
      'source→contract→checks→decision');
  stdout.writeln(
      'TRILEMMA_APPROVAL: ${trilemmaApproved ? 'APPROVE' : 'REJECT'} · '
      'completeness=${axes['completeness']['status']} '
      'purity=${axes['purity']['status']} '
      'performance=${axes['performance']['status']}');
  if (approved && trilemmaApproved && receiptValid) {
    stdout.writeln('SYSTEM_APPROVAL: APPROVE · build/ci-verdict.json');
  } else {
    stderr.writeln('SYSTEM_APPROVAL: REJECT · build/ci-verdict.json');
    exit(1);
  }
}
