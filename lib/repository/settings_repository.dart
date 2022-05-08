import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  late final SharedPreferences _sp;

  Future<void> initial() async {
    _sp = await SharedPreferences.getInstance();
  }

  List<String>? getMenus() {
    return _sp.getStringList('menus');
  }

  Future<void> setMenus(List<String> menus) async {
    await _sp.setStringList('menus', menus);
  }
}
