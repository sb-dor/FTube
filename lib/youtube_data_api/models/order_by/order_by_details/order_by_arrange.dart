class OrderByArrange {
  int id;
  String name;

  OrderByArrange({required this.id, required this.name});

  static final List<OrderByArrange> orderByArrange = [
    OrderByArrange(id: 1, name: "By relevance"),
    OrderByArrange(id: 2, name: "By download date"),
    OrderByArrange(id: 3, name: "By number of views"),
    OrderByArrange(id: 4, name: "By rating"),
  ];
}
