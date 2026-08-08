import 'dart:convert';

/// Canonical line-oriented data format for SSOT and generated contracts.
/// Headers and top-level records make one authored entity one reviewable diff.
Map<String, dynamic> decodeJsonl(String raw) {
  final root = <String, dynamic>{}, seen = <String>{};
  var lineNumber = 0;
  for (final line in raw.split('\n')) {
    lineNumber++;
    if (line.trim().isEmpty) continue;
    final record = jsonDecode(line);
    if (record is! Map)
      throw FormatException('JSONL object required at $lineNumber');
    final type = record['type'];
    if (type == 'header') continue;
    if (type == 'field') {
      final key = '${record['key']}';
      if (!seen.add('field:$key'))
        throw FormatException('duplicate JSONL field $key');
      root[key] = record['value'];
    } else if (type == 'entry') {
      final key = '${record['key']}';
      if (!seen.add('entry:$key'))
        throw FormatException('duplicate JSONL entry $key');
      root[key] = record['value'];
    } else if (type == 'item') {
      final section = '${record['section']}';
      final index = (record['index'] as num?)?.toInt();
      if (index == null || !seen.add('item:$section:$index')) {
        throw FormatException('duplicate or missing JSONL item index $section');
      }
      final items = (root[section] as List? ?? <dynamic>[]);
      if (index != items.length)
        throw FormatException('non-contiguous JSONL item $section:$index');
      items.add(record['value']);
      root[section] = items;
    } else {
      throw FormatException('unknown JSONL record at $lineNumber');
    }
  }
  return root;
}

Map<String, String> decodeJsonlCatalog(String raw) =>
    decodeJsonl(raw).map((key, value) => MapEntry('$key', '$value'));

String encodeJsonl(Map<String, dynamic> root,
    {required String schema, required String document}) {
  final lines = <Map<String, dynamic>>[
    {'type': 'header', 'schema': schema, 'document': document},
  ];
  for (final entry in root.entries) {
    final value = entry.value;
    if (value is List) {
      for (var index = 0; index < value.length; index++) {
        lines.add({
          'type': 'item',
          'section': entry.key,
          'index': index,
          'id': recordId(value[index], index),
          'value': value[index],
        });
      }
    } else {
      lines.add({'type': 'field', 'key': entry.key, 'value': value});
    }
  }
  return '${lines.map(jsonEncode).join('\n')}\n';
}

String encodeJsonlCatalog(Map<String, String> catalog,
    {required String locale}) {
  final lines = <Map<String, dynamic>>[
    {'type': 'header', 'schema': 'lumen-locale-jsonl-v1', 'document': locale},
  ];
  for (final entry in catalog.entries)
    lines.add({'type': 'entry', 'key': entry.key, 'value': entry.value});
  return '${lines.map(jsonEncode).join('\n')}\n';
}

String recordId(dynamic value, int index) {
  if (value is Map) {
    for (final key in ['id', 'key', 'path', 'ref', 'week']) {
      if (value[key] != null) return '${value[key]}';
    }
  }
  return '$index';
}
