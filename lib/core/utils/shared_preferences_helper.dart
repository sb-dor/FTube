import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  late SharedPreferences _sharedPreferences;
  //
  // static SharedPreferencesHelper? _instance;
  //
  // static SharedPreferencesHelper get instance => _instance ??= SharedPreferencesHelper._();

  // SharedPreferencesHelper._();

  Future<void> initPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> saveString({required String key, required String? value}) async {
    if (value == null) return;
    await _sharedPreferences.setString(key, value);
  }

  String? getStringByKey({required String key}) {
    return _sharedPreferences.getString(key);
  }
}
