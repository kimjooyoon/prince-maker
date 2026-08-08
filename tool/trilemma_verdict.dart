import 'dart:convert';
import 'dart:io';

Map<String, List<String>> requiredAxes(String mode) => {
      'completeness': [
        'ci-policy',
        'render-quality-preconditions',
        'story-contract',
        'scenario-variants',
        'generated-trilemma-contract',
        'generated-ssot-docs',
        'review-manifest',
        'static-analysis',
        'tests-and-goldens',
      ],
      'purity': [
        'ci-policy',
        'render-quality-preconditions',
        'story-contract',
        'scenario-variants',
        'campaign-benchmark',
        'generated-trilemma-contract',
        'tests-and-goldens',
      ],
      'performance': [
        'ci-policy',
        'render-quality-preconditions',
        'story-contract',
        'campaign-benchmark',
        'tests-and-goldens',
        if (mode == 'ci') 'wasm-release-build',
      ],
    };

Map<String, dynamic> buildTrilemmaVerdict(
    String mode, List<Map<String, dynamic>> checks) {
  final statuses = {
    for (final check in checks) '${check['id']}': '${check['status']}',
  };
  final axes = <String, dynamic>{};
  for (final entry in requiredAxes(mode).entries) {
    final missing = entry.value.where((id) => statuses[id] == null).toList();
    final failed = entry.value
        .where((id) => statuses[id] != null && statuses[id] != 'pass')
        .toList();
    axes[entry.key] = {
      'status': missing.isEmpty && failed.isEmpty ? 'pass' : 'fail',
      'requiredChecks': entry.value,
      'missingChecks': missing,
      'failedChecks': failed,
    };
  }
  final approved = axes.values.every((axis) => axis['status'] == 'pass');
  final report = {
    'schema': 'lumen-trilemma-verdict-v1',
    'mode': mode,
    'source': 'docs/trilemma-contract.json#axes',
    'decision': approved ? 'approve' : 'reject',
    'axes': axes,
  };
  return report;
}

Map<String, dynamic> writeTrilemmaVerdict(
    String mode, List<Map<String, dynamic>> checks) {
  final report = buildTrilemmaVerdict(mode, checks),
      file = File('build/trilemma-verdict.json')
        ..parent.createSync(recursive: true);
  file.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(report) + '\n');
  return report;
}
