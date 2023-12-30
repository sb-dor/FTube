import 'package:youtube/utils/hive_database_helper/hive_database.dart';

class HiveDatabaseHelper {
  HiveDatabaseHelper._();

  static HiveDatabaseHelper? _instance;

  static HiveDatabaseHelper get instance => _instance ??= HiveDatabaseHelper._();

  final HiveDatabase _database = HiveDatabase.instance;

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
}
