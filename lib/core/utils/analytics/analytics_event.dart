
import 'analytics_builder.dart';
import 'analytics_property.dart';

abstract interface class AnalyticsEvent {
  String get name;

  void buildProperties(AnalyticsBuilder builder);
}

class TabAnalyticEvent implements AnalyticsEvent {
  final String nameOfTab;

  TabAnalyticEvent(this.nameOfTab);

  @override
  void buildProperties(AnalyticsBuilder builder) {
    builder.add(StringAnalyticProperty("screen_tab", nameOfTab));
  }

  @override
  String get name => "tab_clicked";
}
