import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/utils/show_message.dart';
import 'package:youtube/src/common/widget/empty_state_widget.dart';
import 'package:youtube/src/common/widget/list_footer_widget.dart';
import 'package:youtube/src/common/widget/try_again_button.dart';
import 'package:youtube/src/feature/download_deletion/widgets/download_deletion_config_widget.dart';
import 'package:youtube/src/feature/download_player/widgets/download_player_config_widget.dart';
import 'package:youtube/src/feature/downloads/controller/downloads_controller.dart';
import 'package:youtube/src/feature/downloads/models/downloaded_file.dart';
import 'package:youtube/src/feature/downloads/widgets/downloads_config_widget.dart';
import 'package:youtube/src/feature/downloads/widgets/mobile/downloaded_file_row_widget.dart';

class DownloadsMobileWidget extends StatefulWidget {
  const DownloadsMobileWidget({super.key});

  @override
  State<DownloadsMobileWidget> createState() => _DownloadsMobileWidgetState();
}

class _DownloadsMobileWidgetState extends State<DownloadsMobileWidget> {
  late final _scope = DownloadsConfigInhWidget.of(context);
  late final _controller = _scope.downloadsController;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 400) return;
    if (_controller.isProcessing || !_controller.state.canLoadMore) return;
    _scope.paginate();
  }

  void _open(DownloadedFile file) {
    if (!file.exists) {
      showMessage(context, message: Localization.of(context).downloadsFileMissing, isError: true);
      return;
    }
    DownloadPlayerConfigWidget.show(context, file: file);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(scrolledUnderElevation: 0, title: Text(Localization.of(context).downloadsTitle)),
    body: StateConsumer<DownloadsController, DownloadsState>(
      controller: _controller,
      builder: (context, state, _) => switch (state) {
        Downloads$InitialState() ||
        Downloads$InProgressState() => const Center(child: CircularProgressIndicator()),
        Downloads$ErrorState() => Center(child: TryAgainButton(onPressed: _scope.load)),
        Downloads$CompletedState(:final downloads) when downloads.isEmpty => Center(
          child: EmptyStateWidget(message: Localization.of(context).downloadsEmpty),
        ),
        Downloads$CompletedState(:final downloads, :final hasMore) => ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 4, bottom: 10),
          itemCount: downloads.length + (hasMore ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == downloads.length) return const ListFooterWidget();
            final file = downloads[index];
            return DownloadedFileRowWidget(
              key: ValueKey(file.id),
              file: file,
              onTap: () => _open(file),
              onDelete: () => DownloadDeletionConfigWidget.show(context, file: file),
            );
          },
        ),
      },
    ),
  );
}
