class DownloadingType {
  final int id;
  final String name;
  final String eventName;

  DownloadingType({
    required this.id,
    required this.name,
    required this.eventName,
  });

  DownloadingType clone() => DownloadingType(id: id, name: name,eventName: eventName );

  static List<DownloadingType> types = [
    DownloadingType(id: 1, name: "Download sound", eventName: "sound"),
    DownloadingType(id: 2, name: "Download video", eventName: "video"),
  ];
}
