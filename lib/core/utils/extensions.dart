import 'enums.dart';

abstract class EnumExtensions {
  static LiveBroadcastContent liveBroadcastContentJson(String field) {
    switch (field) {
      case "none":
        return LiveBroadcastContent.none;
      case "live":
        return LiveBroadcastContent.live;
      default:
        return LiveBroadcastContent.none;
    }
  }
}

extension StringEx on String {
  int? toInt() {
    return int.tryParse(this);
  }
}

extension ListEx on List {
  List<T> limit<T>({int limit = 15}) {
    if (length >= limit) {
      return take(limit).toList() as List<T>;
    } else {
      return this as List<T>;
    }
  }

  void removeFirst() {
    if (isNotEmpty) removeAt(0);
  }
}
