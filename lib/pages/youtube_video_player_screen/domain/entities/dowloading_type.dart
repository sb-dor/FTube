class DownloadingType {
  int id;
  String name;

  DownloadingType({
    required this.id,
    required this.name,
  });

  DownloadingType clone() => DownloadingType(id: id, name: name);

  static List<DownloadingType> types = [
    DownloadingType(id: 1, name: "Download sound"),
    DownloadingType(id: 2, name: "Download video"),
  ];
}
