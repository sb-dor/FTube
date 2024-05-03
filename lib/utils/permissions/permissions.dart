import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class Permissions {
  Future<void> settingsAppOpener() async {
    await openAppSettings();
  }

  Future<bool> manageExternalStoragePermission() async {
    final checkPermissionForManagingExternalStorage = await Permission.manageExternalStorage.status;

    if (checkPermissionForManagingExternalStorage != PermissionStatus.granted) {
      final permissionForManagingStorage = await Permission.manageExternalStorage.request();

      debugPrint("permission for managing external storage denied");

      return permissionForManagingStorage != PermissionStatus.granted;
    }
    return false;
  }

  Future<bool> storagePermission() async {
    final checkPermissionForStorage = await Permission.storage.status;

    if (checkPermissionForStorage != PermissionStatus.granted) {
      final permissionForStorage = await Permission.storage.request();

      debugPrint("permission for managing storage denied");
      return permissionForStorage != PermissionStatus.granted;
    }
    return false;
  }
}
