import 'dart:convert';
import 'dart:io';

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
    const GateCheck('ci-policy', 'dart', ['run', 'tool/verify_ci_policy.dart']),
    const GateCheck('story-contract', 'dart', ['run', 'tool/verify_game.dart']),
    const GateCheck(
        'campaign-benchmark', 'dart', ['run', 'tool/benchmark_game.dart']),
    const GateCheck('generated-trilemma-contract', 'dart',
        ['run', 'tool/generate_trilemma_contract.dart', '--check']),
    const GateCheck('generated-ssot-docs', 'dart',
        ['run', 'tool/generate_ssot_docs.dart', '--check']),
    const GateCheck(
        'review-manifest', 'dart', ['run', 'tool/verify_review_manifest.dart']),
    const GateCheck('static-analysis', 'flutter', ['analyze']),
    const GateCheck('tests-and-goldens', 'flutter', ['test']),
    if (mode == 'ci')
      const GateCheck('wasm-release-build', 'flutter',
          ['build', 'web', '--wasm', '--release']),
    const GateCheck('diff-whitespace', 'git', ['diff', '--check']),
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
  if (approved) {
    stdout.writeln('SYSTEM_APPROVAL: APPROVE · build/ci-verdict.json');
  } else {
    stderr.writeln('SYSTEM_APPROVAL: REJECT · build/ci-verdict.json');
    exit(1);
  }
}
