import 'package:floor/floor.dart';

class BaseDownloadedFileModel {
  @PrimaryKey(autoGenerate: true)
  int? id;

  String? name;

  @ColumnInfo(name: "downloaded_path")
  String? downloadedPath;

  @ColumnInfo(name: "image_path")
  String? imagePath;

  String? views;

  @ColumnInfo(name: "created_at")
  String? createdAt;

  @ColumnInfo(name: "channel_name")
  String? channelName;

  @ignore
  bool savingToSpecificPath;

  BaseDownloadedFileModel({
    required this.id,
    required this.name,
    required this.downloadedPath,
    required this.imagePath,
    required this.views,
    required this.createdAt,
    required this.channelName,
    required this.savingToSpecificPath,
  });
}
