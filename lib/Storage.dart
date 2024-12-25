import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static Future<void> storeVariable(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> loadVariable(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}