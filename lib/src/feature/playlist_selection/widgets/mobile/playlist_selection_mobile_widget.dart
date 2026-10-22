import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/common/utils/show_message.dart';
import 'package:youtube/src/common/widget/try_again_button.dart';
import 'package:youtube/src/feature/playlist_creation/widgets/playlist_creation_config_widget.dart';
import 'package:youtube/src/feature/playlist_selection/controller/playlist_selection_controller.dart';
import 'package:youtube/src/feature/playlist_selection/controller/playlist_selection_save_controller.dart';
import 'package:youtube/src/feature/playlist_selection/models/playlist_option.dart';
import 'package:youtube/src/feature/playlist_selection/widgets/playlist_selection_config_widget.dart';

class PlaylistSelectionMobileWidget extends StatefulWidget {
  const PlaylistSelectionMobileWidget({super.key});

  @override
  State<PlaylistSelectionMobileWidget> createState() => _PlaylistSelectionMobileWidgetState();
}

class _PlaylistSelectionMobileWidgetState extends State<PlaylistSelectionMobileWidget> {
  late final _scope = PlaylistSelectionConfigInhWidget.of(context);
  late final _controller = _scope.playlistSelectionController;
  late final _saveController = _scope.playlistSelectionSaveController;
  late final _dataController = _scope.playlistSelectionDataController;

  void _onSaveState(
    BuildContext context,
    PlaylistSelectionSaveController controller,
    PlaylistSelectionSaveState previous,
    PlaylistSelectionSaveState current,
  ) {
    final l10n = Localization.of(context);
    switch (current) {
      case PlaylistSelectionSave$CompletedState(:final playlistId):
        final name = switch (_controller.state) {
          PlaylistSelection$CompletedState(:final playlists) =>
            playlists.where((playlist) => playlist.id == playlistId).firstOrNull?.name,
          _ => null,
        };
        showMessage(
          context,
          message: playlistId == null
              ? l10n.playlistSelectionRemoved
              : l10n.playlistSelectionSaved(name ?? ''),
        );
        Navigator.pop(context);
      case PlaylistSelectionSave$ErrorState():
        showMessage(context, message: l10n.errorGeneric, isError: true);
      case PlaylistSelectionSave$InitialState() || PlaylistSelectionSave$InProgressState():
        break;
    }
  }

  void _done() {
    if (!_scope.save()) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    return StateConsumer<PlaylistSelectionSaveController, PlaylistSelectionSaveState>(
      controller: _saveController,
      listener: _onSaveState,
      builder: (context, saveState, _) {
        final saving = saveState is PlaylistSelectionSave$InProgressState;
        return PopScope(
          canPop: !saving,
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            expand: false,
            builder: (context, scrollController) => ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: ColoredBox(
                color: Colors.white,
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 6, top: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.playlistSelectionTitle,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: saving
                                  ? null
                                  : () => PlaylistCreationConfigWidget.show(
                                      context,
                                      onCreated: _dataController.select,
                                    ),
                              icon: const Icon(Icons.add, color: AppColors.accent, size: 20),
                              label: Text(
                                l10n.playlistSelectionNew,
                                style: const TextStyle(color: AppColors.accent, fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 10, color: Colors.grey.shade300),
                      Expanded(
                        child: StateConsumer<PlaylistSelectionController, PlaylistSelectionState>(
                          controller: _controller,
                          builder: (context, state, _) => switch (state) {
                            PlaylistSelection$InitialState() ||
                            PlaylistSelection$InProgressState() => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            PlaylistSelection$ErrorState() => Center(
                              child: TryAgainButton(onPressed: _scope.load),
                            ),
                            PlaylistSelection$CompletedState(:final playlists)
                                when playlists.isEmpty =>
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    l10n.playlistSelectionEmpty,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            PlaylistSelection$CompletedState(:final playlists) => ListenableBuilder(
                              listenable: _dataController,
                              builder: (context, _) => ListView.builder(
                                controller: scrollController,
                                itemCount: playlists.length,
                                itemBuilder: (context, index) => _PlaylistOptionRow(
                                  playlist: playlists[index],
                                  selected: _dataController.selectedId == playlists[index].id,
                                  onTap: saving
                                      ? null
                                      : () => _dataController.toggle(playlists[index].id),
                                ),
                              ),
                            ),
                          },
                        ),
                      ),
                      Divider(height: 10, color: Colors.grey.shade300),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6, bottom: 6),
                          child: saving
                              ? const Padding(
                                  padding: EdgeInsets.all(14),
                                  child: SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : TextButton.icon(
                                  onPressed: _done,
                                  icon: const Icon(Icons.check, size: 20, color: AppColors.accent),
                                  label: Text(
                                    l10n.done,
                                    style: const TextStyle(fontSize: 18, color: AppColors.accent),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlaylistOptionRow extends StatelessWidget {
  const _PlaylistOptionRow({required this.playlist, required this.selected, required this.onTap});

  final PlaylistOption playlist;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        children: [
          Checkbox(
            activeColor: AppColors.accent,
            value: selected,
            onChanged: onTap == null ? null : (_) => onTap!(),
          ),
          Expanded(
            child: Text(
              playlist.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ),
  );
}
