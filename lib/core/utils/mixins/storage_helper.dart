import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

mixin class StorageHelper {
  Future<Directory?> getStorage() async {
    late final Directory? getExternalStoragePath;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      getExternalStoragePath = await getApplicationDocumentsDirectory();
    } else {
      getExternalStoragePath = await getExternalStorageDirectory();
    }

    // debugPrint"external path: ${getExternalStoragePath?.path}");
    return getExternalStoragePath;
  }
}
