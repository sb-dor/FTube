import 'package:flutter/material.dart';
import 'package:youtube/src/feature/history_deletion/controller/history_deletion_controller.dart';
import 'package:youtube/src/feature/history_deletion/data/history_deletion_repository.dart';
import 'package:youtube/src/feature/history_deletion/widgets/history_deletion_dialog_widget.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';

/// Provides [HistoryDeletionConfigWidgetState] to the history deletion dialog.
class HistoryDeletionConfigInhWidget extends InheritedWidget {
  const HistoryDeletionConfigInhWidget({required this.state, required super.child, super.key});

  final HistoryDeletionConfigWidgetState state;

  static HistoryDeletionConfigWidgetState of(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<HistoryDeletionConfigInhWidget>()
        ?.widget;
    assert(widget != null, 'HistoryDeletionConfigInhWidget was not found in the widget tree');
    return (widget! as HistoryDeletionConfigInhWidget).state;
  }

  @override
  bool updateShouldNotify(covariant HistoryDeletionConfigInhWidget oldWidget) => false;
}

/// Confirms and removes one video from the watch history, or clears the whole history.
class HistoryDeletionConfigWidget extends StatefulWidget {
  const HistoryDeletionConfigWidget({
    required this.builder,
    super.key,
    this.videoId,
    this.onSuccessfullyDelete,
  });

  /// Asks to remove [videoId] from the history, or to clear the whole history when it is null.
  /// Completes when the dialog closes.
  static Future<void> show(
    BuildContext context, {
    String? videoId,
    VoidCallback? onSuccessfullyDelete,
  }) => showDialog<void>(
    context: context,
    builder: (context) => HistoryDeletionConfigWidget(
      videoId: videoId,
      onSuccessfullyDelete: onSuccessfullyDelete,
      builder: (context) => const HistoryDeletionDialogWidget(),
    ),
  );

  /// The video to remove; null clears the whole history.
  final String? videoId;
  final WidgetBuilder builder;
  final VoidCallback? onSuccessfullyDelete;

  @override
  State<HistoryDeletionConfigWidget> createState() => HistoryDeletionConfigWidgetState();
}

class HistoryDeletionConfigWidgetState extends State<HistoryDeletionConfigWidget> {
  late final HistoryDeletionController historyDeletionController;
  late final String? videoId = widget.videoId;
  late final VoidCallback? onSuccessfullyDelete = widget.onSuccessfullyDelete;

  @override
  void initState() {
    super.initState();
    historyDeletionController = HistoryDeletionController(
      historyDeletionRepository: HistoryDeletionRepositoryImpl(
        database: DependenciesScope.of(context).database,
      ),
    );
  }

  @override
  void dispose() {
    historyDeletionController.dispose();
    super.dispose();
  }

  /// Removes the video, or clears the history when there is none.
  void confirm() => switch (videoId) {
    final videoId? => historyDeletionController.remove(videoId),
    null => historyDeletionController.clear(),
  };

  @override
  Widget build(BuildContext context) =>
      HistoryDeletionConfigInhWidget(state: this, child: widget.builder(context));
}
