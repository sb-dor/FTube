import 'package:flutter/foundation.dart';
import 'package:youtube/src/feature/trending/models/trending_category.dart';

/// The selected trending category.
class TrendingDataController with ChangeNotifier {
  TrendingCategory _category = TrendingCategory.now;

  TrendingCategory get category => _category;

  /// Returns false when [category] is already selected.
  bool select(TrendingCategory category) {
    if (_category == category) return false;
    _category = category;
    notifyListeners();
    return true;
  }
}
