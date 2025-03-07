import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveDatabase {
  // HiveDatabase._();

  // static HiveDatabase? _instance;

  // static HiveDatabase get instance => _instance ??= HiveDatabase._();

  Future<void> initHive() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);
    await BoxCollection.open(
      'hive_database_name', // name of database
      {
        'search_data', // name of boxes (tables)
      },
      path: directory.path,
    );
  }

  // every time whenever we put data to box we will put like "List<Map<String, dynamic>>" data
  // that is why if we want to get data we will get in in this type "List<Map<String, dynamic>>"

  // the reason that i created this box like List<Map<String, dynamic>> is that i wanted to make it
  // same to sqflite database
  Future<List<Map<String, dynamic>>> getFromBox({required String boxName}) async {
    late Box box;
    if (Hive.isBoxOpen(boxName)) {
      box = Hive.box(boxName);
    } else {
      box = await Hive.openBox(boxName);
    }
    // get by key (key name is "values")
    final values = box.get('values'); // you can name this "values" what event you want;

    final List<dynamic> results = values ?? [];

    return results.map(_convertMap).toList();
  }

  Future<void> insert({required String boxName, required Map<String, dynamic> value}) async {
    late Box box;
    if (Hive.isBoxOpen(boxName)) {
      box = Hive.box(boxName);
    } else {
      box = await Hive.openBox(boxName);
    }

    /// get by key (key name is ["values"])
    final values = box.get('values');

    /// you can name this ["values"] what event you want;

    final List<dynamic> results = values ?? [];

    final List<Map<String, dynamic>> boxValues = results.map(_convertMap).toList();

    boxValues.add(value);

    box.put('values', boxValues);
  }

  Future<void> delete({
    required String boxName,
    required String key,
    required dynamic value,
  }) async {
    late Box box;
    if (Hive.isBoxOpen(boxName)) {
      box = Hive.box(boxName);
    } else {
      box = await Hive.openBox(boxName);
    }
    final values = await box.get('values');

    /// you can name this ["values"] what event you want;

    final List<dynamic> tempList = values ?? [];

    final List<Map<String, dynamic>> boxValues = tempList.map(_convertMap).toList();

    if (boxValues.isEmpty) return;

    boxValues.removeWhere((element) => element.containsKey(key) && element[key] == value);

    box.put('values', boxValues);

    /// you can name this ["values"] what event you want;
  }

  Future<void> deleteAll({required String boxName}) async {
    late Box box;
    if (Hive.isBoxOpen(boxName)) {
      box = Hive.box(boxName);
    } else {
      box = await Hive.openBox(boxName);
    }
    box.put('values', <Map<String, dynamic>>[]);
  }

  Future<void> update({
    required String boxName,
    required String key,
    required dynamic value,
    required Map<String, dynamic> updatingValue,
  }) async {
    late Box box;

    if (Hive.isBoxOpen(boxName)) {
      box = Hive.box(boxName);
    } else {
      box = await Hive.openBox(boxName);
    }

    final values = await box.get('values');

    /// you can name this ["values"] what event you want;

    final List<dynamic> tempList = values ?? [];

    final List<Map<String, dynamic>> boxValues = tempList.map(_convertMap).toList();

    if (boxValues.isEmpty) return;

    final valueIndex = boxValues.indexWhere(
      (element) => element.containsKey(key) && element[key] == value,
    );

    boxValues.removeWhere((element) => element.containsKey(key) && element[key] == value);

    boxValues.insert(valueIndex, updatingValue);

    box.put('values', boxValues);

    /// you can name this ["values"] what event you want;
  }

  Map<String, dynamic> _convertMap(dynamic originalMap) {
    originalMap = originalMap as Map<dynamic, dynamic>;

    final Map<String, dynamic> newMap = {};

    originalMap.forEach((key, value) {
      if (key is String) {
        newMap[key] = value;
      } else {
        newMap[key.toString()] = value;
      }
      if (value is Map<dynamic, dynamic>) {
        newMap[key.toString()] = _convertMap(value);
      }
    });

    return newMap;
  }
}
