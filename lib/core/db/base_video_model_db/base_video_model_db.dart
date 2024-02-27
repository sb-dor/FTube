import 'package:floor/floor.dart';

class BaseVideoModelDb {
  @PrimaryKey(autoGenerate: true)
  int? id;

  String? videoId;

  String? videoThumbnailUrl;

  String? views;

  String? duration;

  String? title;

  String? channelName;

  String? channelThumb;

  String? videoDate;

  @ColumnInfo(name: 'date_time')
  String? dateTime;

  BaseVideoModelDb({
    required this.id,
    required this.videoId,
    required this.videoThumbnailUrl,
    required this.views,
    required this.duration,
    required this.title,
    required this.channelName,
    required this.channelThumb,
    required this.videoDate,
    required this.dateTime,
  });
}
