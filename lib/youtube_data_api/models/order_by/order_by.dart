import 'order_by_details/order_by_arrange.dart';
import 'order_by_details/order_by_time.dart';
import 'order_by_details/order_by_type.dart';

class OrderBy {
  String id;
  OrderByTime? orderByTime;
  OrderByType? orderByType;
  OrderByArrange? orderByArrange;

  OrderBy({
    required this.id,
    this.orderByTime,
    this.orderByType,
    this.orderByArrange,
  });

  static final List<OrderBy> orderBy = [
    OrderBy(
      id: "EgQIARAB",
      orderByType: OrderByType.orderByType.first,
      orderByTime: OrderByTime.orderByTimes.first,
      orderByArrange: OrderByArrange.orderByArrange.first,
    ),
    OrderBy(
      id: "EgQIAhAB",
      orderByType: OrderByType.orderByType.first,
      orderByTime: OrderByTime.orderByTimes[1],
      orderByArrange: OrderByArrange.orderByArrange.first,
    ),
    OrderBy(
      id: "EgQIAxAB",
      orderByType: OrderByType.orderByType.first,
      orderByTime: OrderByTime.orderByTimes[2],
      orderByArrange: OrderByArrange.orderByArrange.first,
    ),
    OrderBy(
      id: "EgQIBBAB",
      orderByType: OrderByType.orderByType.first,
      orderByTime: OrderByTime.orderByTimes[3],
      orderByArrange: OrderByArrange.orderByArrange.first,
    ),
    OrderBy(
      id: "EgQIBRAB",
      orderByType: OrderByType.orderByType.first,
      orderByTime: OrderByTime.orderByTimes[4],
      orderByArrange: OrderByArrange.orderByArrange.first,
    ),
  ];
}
