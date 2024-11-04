class OrderByType {
  int? id;
  String? name;

  OrderByType({required this.id, required this.name});

  static final List<OrderByType> orderByType = [
    OrderByType(id: 1, name: "Videos"),
    // OrderByType(id: 2, name: "Channels"),
    // OrderByType(id: 3, name: "Playlists"),
    OrderByType(id: 4, name: "Films"),
  ];
}
