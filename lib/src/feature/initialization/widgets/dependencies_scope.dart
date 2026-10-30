import 'package:flutter/widgets.dart';
import 'package:youtube/src/feature/initialization/models/dependencies.dart';

/// Provides [Dependencies] to the widget tree.
class DependenciesScope extends InheritedWidget {
  const DependenciesScope({required this.dependencies, required super.child, super.key});

  final Dependencies dependencies;

  /// The closest [Dependencies], or null when there is none.
  static Dependencies? maybeOf(BuildContext context) =>
      (context.getElementForInheritedWidgetOfExactType<DependenciesScope>()?.widget
              as DependenciesScope?)
          ?.dependencies;

  /// The closest [Dependencies]; throws when there is none.
  static Dependencies of(BuildContext context) =>
      maybeOf(context) ?? _notFoundInheritedWidgetOfExactType();

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
    'DependenciesScope was not found in the widget tree; '
        'wrap the app with Dependencies.inject(child: ...)',
    'context',
  );

  @override
  bool updateShouldNotify(covariant DependenciesScope oldWidget) => false;
}
