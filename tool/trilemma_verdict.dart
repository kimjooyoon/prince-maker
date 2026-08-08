import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

Map<String, List<String>> requiredAxes(String mode) => {
      'completeness': [
        'jsonl-contract',
        'ci-policy',
        'decision-proof-preconditions',
        'render-quality-preconditions',
        'story-contract',
        'content-depth',
        'gameplay-fun',
        'quality-score',
        'scenario-variants',
        'generated-development-goals',
        'generated-trilemma-contract',
        'generated-ssot-docs',
        'generated-trilemma-docs',
        'review-manifest',
        'static-analysis',
        'tests-and-goldens',
      ],
      'purity': [
        'jsonl-contract',
        'ci-policy',
        'decision-proof-preconditions',
        'render-quality-preconditions',
        'story-contract',
        'gameplay-fun',
        'quality-score',
        'scenario-variants',
        'campaign-benchmark',
        'generated-development-goals',
        'generated-trilemma-contract',
        'generated-trilemma-docs',
        'tests-and-goldens',
      ],
      'performance': [
        'jsonl-contract',
        'ci-policy',
        'decision-proof-preconditions',
        'render-quality-preconditions',
        'story-contract',
        'quality-score',
        'campaign-benchmark',
        'generated-development-goals',
        'generated-trilemma-docs',
        'tests-and-goldens',
        if (mode == 'ci') 'wasm-release-build',
      ],
    };

const _sourceFiles = [
  {'ref': 'story/story.jsonl#root', 'path': 'story/story.jsonl'},
  {
    'ref': 'docs/trilemma-contract.jsonl#axes',
    'path': 'docs/trilemma-contract.jsonl'
  },
  {
    'ref': 'docs/review-manifest.jsonl#entries',
    'path': 'docs/review-manifest.jsonl'
  },
];

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();

List<Map<String, dynamic>> _sourceDigests() => [
      for (final source in _sourceFiles)
        {
          'ref': source['ref'],
          'sha256':
              sha256.convert(File(source['path']!).readAsBytesSync()).toString()
        }
    ];

Map<String, dynamic> _decisionPayload(Map<String, dynamic> report) => {
      'schema': report['schema'],
      'mode': report['mode'],
      'sourceDigests': (report['closure'] as Map)['sourceDigests'],
      'checksDigest': (report['closure'] as Map)['checksDigest'],
      'decision': report['decision'],
      'axes': report['axes'],
    };

bool verifyTrilemmaReceipt(Map<String, dynamic> report) {
  if (report['schema'] != 'lumen-trilemma-verdict-v1') return false;
  final closure = report['closure'];
  if (closure is! Map ||
      closure['stages'].toString() !=
          '[ssot, generated-contract, gate-evidence, system-verdict]') {
    return false;
  }
  final sources = closure['sourceDigests'];
  if (sources is! List || jsonEncode(sources) != jsonEncode(_sourceDigests()))
    return false;
  final checks = report['checks'];
  if (checks is! List || closure['checksDigest'] != _digest(checks))
    return false;
  return closure['decisionHash'] == _digest(_decisionPayload(report));
}

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
  final sourceDigests = _sourceDigests(),
      checksDigest = _digest(checks),
      report = <String, dynamic>{
        'schema': 'lumen-trilemma-verdict-v1',
        'mode': mode,
        'source': 'docs/trilemma-contract.jsonl#axes',
        'decision': approved ? 'approve' : 'reject',
        'axes': axes,
        'checks': checks,
      };
  report['closure'] = {
    'stages': ['ssot', 'generated-contract', 'gate-evidence', 'system-verdict'],
    'sourceDigests': sourceDigests,
    'checksDigest': checksDigest,
    'decisionHash': '',
  };
  (report['closure'] as Map)['decisionHash'] =
      _digest(_decisionPayload(report));
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
