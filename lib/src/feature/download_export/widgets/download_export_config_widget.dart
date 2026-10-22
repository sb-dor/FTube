import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/utils/show_message.dart';
import 'package:youtube/src/feature/download_export/controller/download_export_controller.dart';
import 'package:youtube/src/feature/download_export/data/download_export_repository.dart';
import 'package:youtube/src/feature/downloads/models/downloaded_file.dart';

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
      downloadExportRepository: DownloadExportRepositoryImpl(),
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

/// "Save in Gallery" (video) or "Save in Downloads" (audio) button for one downloaded file.
/// Needs a [DownloadExportConfigWidget] above it.
class DownloadExportButtonWidget extends StatefulWidget {
  const DownloadExportButtonWidget({required this.file, super.key});

  final DownloadedFile file;

  @override
  State<DownloadExportButtonWidget> createState() => _DownloadExportButtonWidgetState();
}

class _DownloadExportButtonWidgetState extends State<DownloadExportButtonWidget> {
  late final _scope = DownloadExportConfigInhWidget.of(context);
  late final _controller = _scope.downloadExportController;

  @override
  Widget build(BuildContext context) {
    final localization = Localization.of(context);
    final file = widget.file;
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.state.isSaving(file.id)) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        return IconButton(
          tooltip: file.isVideo
              ? localization.downloadExportSaveInGallery
              : localization.downloadExportSaveInDownloads,
          onPressed: () => _scope.export(file),
          icon: file.isVideo
              ? Image.asset('assets/download_icons/gallery_save.png', width: 25, height: 25)
              : const Icon(Icons.download, size: 20),
        );
      },
    );
  }
}
