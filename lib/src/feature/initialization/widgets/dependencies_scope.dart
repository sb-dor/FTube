import 'package:flutter/widgets.dart';
import 'package:youtube/src/feature/initialization/models/dependencies.dart';

/// Provides [Dependencies] to the widget tree.
class DependenciesScope extends InheritedWidget {
  const DependenciesScope({required this.dependencies, required super.child, super.key});

  final Dependencies dependencies;

  /// The closest [Dependencies]; throws when there is none.
  static Dependencies of(BuildContext context) {
    final widget = context.getElementForInheritedWidgetOfExactType<DependenciesScope>()?.widget;
    assert(widget != null, 'DependenciesScope was not found in the widget tree');
    return (widget! as DependenciesScope).dependencies;
  }

  @override
  bool updateShouldNotify(covariant DependenciesScope oldWidget) => false;
}
