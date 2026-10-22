import 'package:flutter/foundation.dart';
import 'package:youtube/src/feature/feed/models/feed_category.dart';

/// The selected feed category.
class FeedDataController with ChangeNotifier {
  FeedCategory _category = FeedCategory.all;

  FeedCategory get category => _category;

  /// Returns false when [category] is already selected.
  bool select(FeedCategory category) {
    if (_category == category) return false;
    _category = category;
    notifyListeners();
    return true;
  }
}
