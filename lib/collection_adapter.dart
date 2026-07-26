import 'dart:convert';

abstract interface class CollectionPort {
  List<Map<String, dynamic>> read();
  void record(String endingId, int rank);
  void clear();
}

class MemoryCollectionAdapter implements CollectionPort {
  String? value;
  @override List<Map<String, dynamic>> read() => _decode(value);
  @override void record(String endingId, int rank) { final entries = read(); final i = entries.indexWhere((e) => e['id'] == endingId); if (i < 0) { entries.add({'id': endingId, 'rank': rank}); } else if ((entries[i]['rank'] as int) < rank) entries[i]['rank'] = rank; entries.sort((a, b) => '${a['id']}'.compareTo('${b['id']}')); value = jsonEncode(entries); }
  @override void clear() => value = null;
}

List<Map<String, dynamic>> _decode(String? raw) { if (raw == null || raw.isEmpty) return []; try { return (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e as Map)).toList(); } catch (_) { return []; } }
