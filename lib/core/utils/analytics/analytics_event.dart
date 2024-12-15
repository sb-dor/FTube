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
    builder.add(StringAnalyticProperty(name, nameOfTab));
  }

  @override
  String get name => "screen_tab";
}

class TypeDownloaderButtonEvent implements AnalyticsEvent {
  final String type;

  TypeDownloaderButtonEvent(this.type);

  @override
  void buildProperties(AnalyticsBuilder builder) {
    builder.add(StringAnalyticProperty(name, type));
  }

  @override
  String get name => "download_type";
}
