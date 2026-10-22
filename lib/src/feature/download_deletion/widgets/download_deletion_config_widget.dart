import 'package:flutter/material.dart';
import 'package:youtube/src/feature/download_deletion/controller/download_deletion_controller.dart';
import 'package:youtube/src/feature/download_deletion/data/download_deletion_repository.dart';
import 'package:youtube/src/feature/download_deletion/widgets/download_deletion_dialog_widget.dart';
import 'package:youtube/src/feature/downloads/models/downloaded_file.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';

class DownloadDeletionConfigInhWidget extends InheritedWidget {
  const DownloadDeletionConfigInhWidget({required this.state, required super.child, super.key});

  final DownloadDeletionConfigWidgetState state;

  static DownloadDeletionConfigWidgetState of(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<DownloadDeletionConfigInhWidget>()
        ?.widget;
    assert(widget != null, 'DownloadDeletionConfigInhWidget was not found in the widget tree');
    return (widget! as DownloadDeletionConfigInhWidget).state;
  }

  @override
  bool updateShouldNotify(covariant DownloadDeletionConfigInhWidget oldWidget) => false;
}

/// Confirmation dialog that deletes a downloaded file and its database row.
class DownloadDeletionConfigWidget extends StatefulWidget {
  const DownloadDeletionConfigWidget({
    required this.file,
    required this.builder,
    super.key,
    this.onSuccessfullyDelete,
  });

  /// Asks for confirmation, then deletes [file]. Completes when the dialog closes.
  static Future<void> show(
    BuildContext context, {
    required DownloadedFile file,
    VoidCallback? onSuccessfullyDelete,
  }) => showDialog<void>(
    context: context,
    builder: (context) => DownloadDeletionConfigWidget(
      file: file,
      onSuccessfullyDelete: onSuccessfullyDelete,
      builder: (context) => const DownloadDeletionDialogWidget(),
    ),
  );

  final DownloadedFile file;
  final WidgetBuilder builder;
  final VoidCallback? onSuccessfullyDelete;

  @override
  State<DownloadDeletionConfigWidget> createState() => DownloadDeletionConfigWidgetState();
}

class DownloadDeletionConfigWidgetState extends State<DownloadDeletionConfigWidget> {
  late final DownloadDeletionController downloadDeletionController;
  late final DownloadedFile file = widget.file;
  late final VoidCallback? onSuccessfullyDelete = widget.onSuccessfullyDelete;

  @override
  void initState() {
    super.initState();
    downloadDeletionController = DownloadDeletionController(
      downloadDeletionRepository: DownloadDeletionRepositoryImpl(
        database: DependenciesScope.of(context).database,
      ),
    );
  }

  @override
  void dispose() {
    downloadDeletionController.dispose();
    super.dispose();
  }

  void delete() => downloadDeletionController.delete(file);

  @override
  Widget build(BuildContext context) =>
      DownloadDeletionConfigInhWidget(state: this, child: widget.builder(context));
}
