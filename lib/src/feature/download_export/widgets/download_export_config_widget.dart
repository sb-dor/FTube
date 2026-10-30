import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/utils/show_message.dart';
import 'package:youtube/src/feature/download_export/controller/download_export_controller.dart';
import 'package:youtube/src/feature/download_export/data/download_export_repository.dart';
import 'package:youtube/src/feature/download_export/models/download_export_destination.dart';
import 'package:youtube/src/feature/download_export/models/download_export_failure.dart';
import 'package:youtube/src/feature/download_export/widgets/mobile/download_export_button_widget.dart';
import 'package:youtube/src/feature/downloads/models/downloaded_file.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';

/// Provides [DownloadExportConfigWidgetState] to [DownloadExportButtonWidget]s below it.
class DownloadExportConfigInhWidget extends InheritedWidget {
  const DownloadExportConfigInhWidget({required this.state, required super.child, super.key});

  final DownloadExportConfigWidgetState state;

  static DownloadExportConfigWidgetState of(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<DownloadExportConfigInhWidget>()
        ?.widget;
    assert(widget != null, 'DownloadExportConfigInhWidget was not found in the widget tree');
    return (widget! as DownloadExportConfigInhWidget).state;
  }

  @override
  bool updateShouldNotify(covariant DownloadExportConfigInhWidget oldWidget) => false;
}

/// Scope for saving downloaded files to the phone; shows the result as a snackbar.
///
/// Wrap a list of downloads in it and put a [DownloadExportButtonWidget] in each row.
class DownloadExportConfigWidget extends StatefulWidget {
  const DownloadExportConfigWidget({required this.child, super.key});

  final Widget child;

  @override
  State<DownloadExportConfigWidget> createState() => DownloadExportConfigWidgetState();
}

class DownloadExportConfigWidgetState extends State<DownloadExportConfigWidget> {
  late final DownloadExportController downloadExportController;

  @override
  void initState() {
    super.initState();
    downloadExportController = DownloadExportController(
      downloadExportRepository: DownloadExportRepositoryImpl(
        mediaStore: DependenciesScope.of(context).deviceMediaStore,
      ),
    );
  }

  @override
  void dispose() {
    downloadExportController.dispose();
    super.dispose();
  }

  /// Video → gallery, audio → Downloads folder.
  void export(DownloadedFile file) => downloadExportController.export(file);

  void _onStateChanged(
    BuildContext context,
    DownloadExportController controller,
    DownloadExportState previous,
    DownloadExportState current,
  ) {
    final localization = Localization.of(context);
    switch (current) {
      case DownloadExport$CompletedState(:final destination):
        showMessage(
          context,
          message: switch (destination) {
            DownloadExportDestination.gallery => localization.downloadExportSavedInGallery,
            DownloadExportDestination.downloads => localization.downloadExportSavedInDownloads,
          },
        );
      case DownloadExport$ErrorState(:final failure):
        showMessage(
          context,
          isError: true,
          message: switch (failure) {
            DownloadExportFailure.fileMissing => localization.downloadsFileMissing,
            DownloadExportFailure.permissionDenied => localization.downloadExportPermissionDenied,
            DownloadExportFailure.failed => localization.errorGeneric,
          },
        );
      case DownloadExport$InitialState() || DownloadExport$InProgressState():
        break;
    }
  }

  @override
  Widget build(BuildContext context) => DownloadExportConfigInhWidget(
    state: this,
    child: StateConsumer<DownloadExportController, DownloadExportState>(
      controller: downloadExportController,
      listener: _onStateChanged,
      buildWhen: (_, _) => false,
      child: widget.child,
    ),
  );
}
