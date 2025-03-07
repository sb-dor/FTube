import 'hive_database.dart';

class HiveDatabaseHelper {
  // HiveDatabaseHelper._();

  // static HiveDatabaseHelper? _instance;

  // static HiveDatabaseHelper get instance => _instance ??= HiveDatabaseHelper._();

  const HiveDatabaseHelper({required HiveDatabase database}) : _database = database;

  final HiveDatabase _database;

  Future<List<String>> getSearchData() async {
    final data = await _database.getFromBox(boxName: 'search_data');
    if (data.isEmpty) return [];
    final firstData = data.first;
    return firstData['data'];
  }

  Future<void> saveSearchData({required List<String> listOfSearch}) async {
    final Map<String, dynamic> dataForSave = {'data': listOfSearch};
    await _database.insert(boxName: 'search_data', value: dataForSave);
  }

  Future<bool> isOverlayShowedForMainScreen() async {
    final data = await _database.getFromBox(boxName: "main_screen_overlay");
    if (data.isEmpty) return false;
    final firstEl = data.first;
    return firstEl['main_screen_overlay_value'];
  }

  Future<void> overlayShowedForMainScreen() async {
    final Map<String, dynamic> dataForSave = {"main_screen_overlay_value": true};
    await _database.insert(boxName: "main_screen_overlay", value: dataForSave);
  }
}
