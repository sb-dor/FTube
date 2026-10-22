import 'package:flutter/material.dart';
import 'package:youtube/src/feature/download_export/widgets/download_export_config_widget.dart';
import 'package:youtube/src/feature/downloads/controller/downloads_controller.dart';
import 'package:youtube/src/feature/downloads/data/downloads_repository.dart';
import 'package:youtube/src/feature/downloads/widgets/mobile/downloads_mobile_widget.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';

/// Provides [DownloadsConfigWidgetState] to the downloads screen.
class DownloadsConfigInhWidget extends InheritedWidget {
  const DownloadsConfigInhWidget({required this.state, required super.child, super.key});

  final DownloadsConfigWidgetState state;

  static DownloadsConfigWidgetState of(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<DownloadsConfigInhWidget>()
        ?.widget;
    assert(widget != null, 'DownloadsConfigInhWidget was not found in the widget tree');
    return (widget! as DownloadsConfigInhWidget).state;
  }

  @override
  bool updateShouldNotify(covariant DownloadsConfigInhWidget oldWidget) => false;
}

/// "In-App downloads": files downloaded into the app, newest first, updated live.
class DownloadsConfigWidget extends StatefulWidget {
  const DownloadsConfigWidget({super.key});

  /// Opens the downloads screen.
  static Future<void> open(BuildContext context) => Navigator.push<void>(
    context,
    MaterialPageRoute(builder: (context) => const DownloadsConfigWidget()),
  );

  @override
  State<DownloadsConfigWidget> createState() => DownloadsConfigWidgetState();
}

class DownloadsConfigWidgetState extends State<DownloadsConfigWidget> {
  late final DownloadsController downloadsController;

  @override
  void initState() {
    super.initState();
    downloadsController = DownloadsController(
      downloadsRepository: DownloadsRepositoryImpl(
        database: DependenciesScope.of(context).database,
      ),
    );
    watch();
  }

  @override
  void dispose() {
    downloadsController.dispose();
    super.dispose();
  }

  void watch() => downloadsController.watch();

  @override
  Widget build(BuildContext context) => DownloadsConfigInhWidget(
    state: this,
    child: const DownloadExportConfigWidget(child: DownloadsMobileWidget()),
  );
}
