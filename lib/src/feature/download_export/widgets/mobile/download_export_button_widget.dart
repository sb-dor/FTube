import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/feature/download_export/controller/download_export_controller.dart';
import 'package:youtube/src/feature/download_export/widgets/download_export_config_widget.dart';
import 'package:youtube/src/feature/downloads/models/downloaded_file.dart';

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
    return StateConsumer<DownloadExportController, DownloadExportState>(
      controller: _controller,
      builder: (context, state, _) {
        if (state.isSaving(file.id)) {
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
