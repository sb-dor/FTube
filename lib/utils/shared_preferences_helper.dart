import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  late SharedPreferences sharedPreferences;

  static SharedPreferencesHelper? _instance;

  static SharedPreferencesHelper get instance => _instance ??= SharedPreferencesHelper._();

  SharedPreferencesHelper._();

  Future<void> initPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> saveString({required String key, required String value}) async {
    await sharedPreferences.setString(key, value);
  }

  String? getStringByKey({required String key}) {
    return sharedPreferences.getString(key);
  }
}
