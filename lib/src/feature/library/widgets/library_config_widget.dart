import 'package:flutter/material.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';
import 'package:youtube/src/feature/library/controller/library_controller.dart';
import 'package:youtube/src/feature/library/data/library_repository.dart';
import 'package:youtube/src/feature/library/widgets/mobile/library_mobile_widget.dart';

/// Provides [LibraryConfigWidgetState] to the library tab.
class LibraryConfigInhWidget extends InheritedWidget {
  const LibraryConfigInhWidget({required this.state, required super.child, super.key});

  final LibraryConfigWidgetState state;

  static LibraryConfigWidgetState of(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<LibraryConfigInhWidget>()
        ?.widget;
    assert(widget != null, 'LibraryConfigInhWidget was not found in the widget tree');
    return (widget! as LibraryConfigInhWidget).state;
  }

  @override
  bool updateShouldNotify(covariant LibraryConfigInhWidget oldWidget) => false;
}

/// Library tab: recent history, playlists and the in-app downloads entry. Updates by itself
/// whenever the database changes.
class LibraryConfigWidget extends StatefulWidget {
  const LibraryConfigWidget({super.key});

  @override
  State<LibraryConfigWidget> createState() => LibraryConfigWidgetState();
}

class LibraryConfigWidgetState extends State<LibraryConfigWidget> {
  late final LibraryController libraryController;

  @override
  void initState() {
    super.initState();
    libraryController = LibraryController(
      libraryRepository: LibraryRepositoryImpl(database: DependenciesScope.of(context).database),
    );
    watch();
  }

  @override
  void dispose() {
    libraryController.dispose();
    super.dispose();
  }

  void watch() => libraryController.watch();

  @override
  Widget build(BuildContext context) =>
      LibraryConfigInhWidget(state: this, child: const LibraryMobileWidget());
}
