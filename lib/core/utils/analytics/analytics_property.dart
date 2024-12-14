abstract base class AnalyticsProperty<T> {
  final String name;
  final T? value;

  AnalyticsProperty(this.name, this.value);

  Object? get serializableValue => value;
}

final class StringAnalyticProperty extends AnalyticsProperty<String> {
  StringAnalyticProperty(super.name, super.value);
}

final class IntAnalyticProperty extends AnalyticsProperty<int> {
  IntAnalyticProperty(super.name, super.value);
}

final class DoubleAnalyticProperty extends AnalyticsProperty<double> {
  DoubleAnalyticProperty(super.name, super.value);
}

final class BooleanAnalyticProperty extends AnalyticsProperty<bool> {
  BooleanAnalyticProperty(super.name, super.value);

  @override
  Object? get serializableValue {
    if (value == null) return null;
    return value! ? "true" : false;
  }
}
