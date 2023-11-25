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
