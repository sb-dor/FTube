import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:l/l.dart';

/// Product analytics events.
abstract interface class IAnalytics {
  /// A bottom-navigation tab was opened: `home`, `trending` or `library`.
  void screenTab(String tab);

  /// A download type was chosen: `sound` or `video`.
  void downloadType(String type);
}

/// Sends events to Firebase Analytics.
final class FirebaseAnalyticsImpl implements IAnalytics {
  FirebaseAnalyticsImpl({required this._analytics});

  final FirebaseAnalytics _analytics;

  @override
  void screenTab(String tab) => _log('screen_tab', {'screen_tab': tab});

  @override
  void downloadType(String type) => _log('download_type', {'download_type': type});

  void _log(String name, Map<String, Object> parameters) {
    l.d('Analytics | $name $parameters');
    _analytics.logEvent(name: name, parameters: parameters).ignore();
  }
}
