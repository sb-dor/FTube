import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
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

  // get after checking orderTime, orderType or any other orders. If it contains any of it get it
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

    //
    OrderBy(
      id: "EgQIARAE",
      orderByType: OrderByType.orderByType[1], // set 3 after re-commenting orderByType
      orderByTime: OrderByTime.orderByTimes.first,
      orderByArrange: OrderByArrange.orderByArrange.first,
    ),
    OrderBy(
      id: "EgQIAhAE",
      orderByType: OrderByType.orderByType[1], // set 3 after re-commenting orderByType
      orderByTime: OrderByTime.orderByTimes[1],
      orderByArrange: OrderByArrange.orderByArrange.first,
    ),
    OrderBy(
      id: "EgQIAxAE",
      orderByType: OrderByType.orderByType[1], // set 3 after re-commenting orderByType
      orderByTime: OrderByTime.orderByTimes[2],
      orderByArrange: OrderByArrange.orderByArrange.first,
    ),
    OrderBy(
      id: "EgQIBBAE",
      orderByType: OrderByType.orderByType[1], // set 3 after re-commenting orderByType
      orderByTime: OrderByTime.orderByTimes[3],
      orderByArrange: OrderByArrange.orderByArrange.first,
    ),
    OrderBy(
      id: "EgQIBRAE",
      orderByType: OrderByType.orderByType[1], // set 3 after re-commenting orderByType
      orderByTime: OrderByTime.orderByTimes[4],
      orderByArrange: OrderByArrange.orderByArrange.first,
    ),
  ];

  static OrderBy? getOnCheck({
    OrderByType? type,
    OrderByTime? time,
    OrderByArrange? arrange,
  }) {
    debugPrint("type herere: ${type?.id}");
    debugPrint("time herere: ${time?.id}");
    return orderBy.firstWhereOrNull((element) {
      return element.orderByType?.id == type?.id && element.orderByTime?.id == time?.id;
    });
  }
}
