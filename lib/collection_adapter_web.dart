import 'dart:convert';
import 'package:web/web.dart' as web;
import 'collection_adapter.dart';

class BrowserCollectionAdapter extends MemoryCollectionAdapter {
  static const key = 'prince-maker:lumen-collection-v1';
  @override
  List<Map<String, dynamic>> read() =>
      _decode(web.window.localStorage.getItem(key));
  @override
  void record(String endingId, int rank, {List<String> routes = const []}) {
    super.record(endingId, rank, routes: routes);
    web.window.localStorage.setItem(key, value!);
  }

  @override
  void clear() => web.window.localStorage.removeItem(key);
}

CollectionPort createCollectionAdapter() => BrowserCollectionAdapter();

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
