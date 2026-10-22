import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/widget/video_row_widget.dart';
import 'package:youtube/src/feature/download_export/widgets/download_export_config_widget.dart';
import 'package:youtube/src/feature/downloads/models/downloaded_file.dart';

/// One downloaded file: thumbnail with the file type, title, channel, views, a menu with
/// "Delete" and the save-to-phone button. A file that is gone is dimmed and labelled.
class DownloadedFileRowWidget extends StatelessWidget {
  const DownloadedFileRowWidget({
    required this.file,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  final DownloadedFile file;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final localization = Localization.of(context);
    return Opacity(
      opacity: file.exists ? 1 : 0.5,
      child: VideoRowWidget(
        title: file.title.isEmpty ? '-' : file.title,
        thumbnailUrl: file.thumbnailUrl,
        channelName: file.channelName,
        viewsText: file.viewsText,
        badge: file.exists ? file.typeLabel : localization.downloadsFileMissing,
        onTap: onTap,
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<VoidCallback>(
              tooltip: localization.downloadsMore,
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (action) => action(),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: onDelete,
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline, size: 20),
                      const SizedBox(width: 10),
                      Text(localization.delete),
                    ],
                  ),
                ),
              ],
            ),
            if (file.exists) DownloadExportButtonWidget(file: file),
          ],
        ),
      ),
    );
  }
}
