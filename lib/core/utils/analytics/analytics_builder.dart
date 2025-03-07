import 'analytics_property.dart';

class AnalyticsBuilder {
  final List<AnalyticsProperty> _properties;

  AnalyticsBuilder({List<AnalyticsProperty>? properties})
    : _properties = properties ?? <AnalyticsProperty>[];

  void add(AnalyticsProperty property) {
    _properties.add(property);
  }

  Map<String, Object> toJson() {
    final data = <String, Object>{};
    for (final each in _properties) {
      if (each.serializableValue == null) continue;
      data[each.name] = each.serializableValue!;
    }
    return data;
  }
}
