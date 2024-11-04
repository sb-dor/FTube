
class OrderByTime {
  int? id;
  String? name;

  OrderByTime({required this.name, required this.id});

  static final List<OrderByTime> orderByTimes = [
    OrderByTime(name: "In the last hour", id: 1),
    OrderByTime(name: "Today", id: 2),
    OrderByTime(name: "For this week", id: 3),
    OrderByTime(name: "For this month", id: 4),
    OrderByTime(name: "For this year", id: 5),
  ];
}
