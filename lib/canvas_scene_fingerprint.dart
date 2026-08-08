import 'dart:convert';

/// Stable, order-independent state key for Canvas repaint decisions.
String canvasSceneFingerprint(Iterable<Object?> values) =>
    values.map(_stableValue).join('::');

String _stableValue(Object? value) {
  if (value is Map) {
    final entries = value.entries
        .map((entry) => MapEntry('${entry.key}', entry.value))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return '{${entries.map((e) => '${jsonEncode(e.key)}:${_stableValue(e.value)}').join('|')}}';
  }
  if (value is Iterable) return '[${value.map(_stableValue).join('|')}]';
  if (value == null || value is num || value is bool) return '$value';
  return jsonEncode('$value');
}
