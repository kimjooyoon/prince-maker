import 'package:web/web.dart' as web;
import 'game_core.dart';

class BrowserSaveAdapter implements SavePort {
  static const key = 'prince-maker:lumen-save-v6';
  @override String? read() => web.window.localStorage.getItem(key);
  @override void write(String value) => web.window.localStorage.setItem(key, value);
  @override void clear() => web.window.localStorage.removeItem(key);
}

SavePort createSaveAdapter() => BrowserSaveAdapter();
