import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/widget/empty_state_widget.dart';
import 'package:youtube/src/common/widget/try_again_button.dart';
import 'package:youtube/src/feature/video_download/controller/download_options_controller.dart';
import 'package:youtube/src/feature/video_download/models/download_option.dart';
import 'package:youtube/src/feature/video_download/widgets/mobile/download_kind_card.dart';
import 'package:youtube/src/feature/video_download/widgets/mobile/download_option_row.dart';
import 'package:youtube/src/feature/video_download/widgets/video_download_config_widget.dart';

class VideoDownloadSheetWidget extends StatefulWidget {
  const VideoDownloadSheetWidget({super.key});

  @override
  State<VideoDownloadSheetWidget> createState() => _VideoDownloadSheetWidgetState();
}

class _VideoDownloadSheetWidgetState extends State<VideoDownloadSheetWidget> {
  late final _scope = VideoDownloadConfigInhWidget.of(context);
  DownloadKind? _kind;

  void _choose(DownloadKind kind) {
    _scope.chooseKind(kind);
    setState(() => _kind = kind);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    final kind = _kind;
    return SafeArea(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        child: kind == null
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: DownloadKindCard(
                        icon: Icons.music_note,
                        label: l10n.downloadSound,
                        onTap: () => _choose(DownloadKind.audio),
                      ),
                    ),
                    Expanded(
                      child: DownloadKindCard(
                        icon: Icons.videocam_outlined,
                        label: l10n.downloadVideo,
                        onTap: () => _choose(DownloadKind.video),
                      ),
                    ),
                  ],
                ),
              )
            : ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.55),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _kind = null),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Flexible(child: _OptionsList(kind: kind)),
                  ],
                ),
              ),
      ),
    );
  }
}

class _OptionsList extends StatelessWidget {
  const _OptionsList({required this.kind});

  final DownloadKind kind;

  @override
  Widget build(BuildContext context) {
    final scope = VideoDownloadConfigInhWidget.of(context);
    return StateConsumer<DownloadOptionsController, DownloadOptionsState>(
      controller: scope.downloadOptionsController,
      builder: (context, state, _) => switch (state) {
        DownloadOptions$InitialState() || DownloadOptions$InProgressState() => const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
        DownloadOptions$ErrorState() => Center(child: TryAgainButton(onPressed: scope.reload)),
        DownloadOptions$CompletedState(:final options) when options.of(kind).isEmpty => Center(
          child: EmptyStateWidget(message: Localization.of(context).downloadNoOptions),
        ),
        DownloadOptions$CompletedState(:final options) => ListenableBuilder(
          listenable: scope.videoDownloadController,
          builder: (context, _) {
            final items = options.of(kind);
            return ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) => DownloadOptionRow(
                option: items[index],
                recommended: index == 0,
                downloadState: scope.videoDownloadController.state,
                videoId: scope.video.id,
                onDownload: scope.start,
                onCancel: scope.videoDownloadController.cancel,
              ),
            );
          },
        ),
      },
    );
  }
}
