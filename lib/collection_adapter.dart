import 'dart:convert';

abstract interface class CollectionPort {
  List<Map<String, dynamic>> read();
  void record(String endingId, int rank, {List<String> routes});
  void clear();
}

class MemoryCollectionAdapter implements CollectionPort {
  String? value;
  @override
  List<Map<String, dynamic>> read() => _decode(value);
  @override
  void record(String endingId, int rank, {List<String> routes = const []}) {
    final entries = read(), i = entries.indexWhere((e) => e['id'] == endingId);
    final merged = {
      ...routes,
      if (i >= 0)
        ...((entries[i]['routes'] as List?)?.cast<String>() ?? const [])
    }.toList()
      ..sort();
    if (i < 0) {
      entries.add({
        'id': endingId,
        'rank': rank,
        if (merged.isNotEmpty) 'routes': merged
      });
    } else {
      if ((entries[i]['rank'] as int) < rank) entries[i]['rank'] = rank;
      if (merged.isNotEmpty) entries[i]['routes'] = merged;
    }
    entries.sort((a, b) => '${a['id']}'.compareTo('${b['id']}'));
    value = jsonEncode(entries);
  }

  @override
  void clear() => value = null;
}

List<Map<String, dynamic>> _decode(String? raw) {
  if (raw == null || raw.isEmpty) return [];
  try {
    return (jsonDecode(raw) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  } catch (_) {
    return [];
  }
}
