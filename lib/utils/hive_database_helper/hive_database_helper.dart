import 'package:youtube/utils/hive_database_helper/hive_database.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

class HiveDatabaseHelper {
  // HiveDatabaseHelper._();

  // static HiveDatabaseHelper? _instance;

  // static HiveDatabaseHelper get instance => _instance ??= HiveDatabaseHelper._();

  final HiveDatabase _database = locator<HiveDatabase>();

  Future<List<String>> getSearchData() async {
    var data = await _database.getFromBox(boxName: 'search_data');
    if (data.isEmpty) return [];
    var firstData = data.first;
    return firstData['data'];
  }

  Future<void> saveSearchData({required List<String> listOfSearch}) async {
    Map<String, dynamic> dataForSave = {
      'data': listOfSearch,
    };
    await _database.insert(boxName: 'search_data', value: dataForSave);
  }

  Future<bool> isOverlayShowedForMainScreen() async {
    final data = await _database.getFromBox(boxName: "main_screen_overlay");
    if (data.isEmpty) return false;
    final firstEl = data.first;
    return firstEl['main_screen_overlay_value'];
  }

  Future<void> overlayShowedForMainScreen() async {
    Map<String, dynamic> dataForSave = {"main_screen_overlay_value": true};
    await _database.insert(boxName: "main_screen_overlay", value: dataForSave);
  }
}
