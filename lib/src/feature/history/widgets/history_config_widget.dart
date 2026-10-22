import 'package:flutter/material.dart';
import 'package:youtube/src/feature/history/controller/history_controller.dart';
import 'package:youtube/src/feature/history/data/history_repository.dart';
import 'package:youtube/src/feature/history/widgets/mobile/history_mobile_widget.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';

/// Provides [HistoryConfigWidgetState] to the history screen.
class HistoryConfigInhWidget extends InheritedWidget {
  const HistoryConfigInhWidget({required this.state, required super.child, super.key});

  final HistoryConfigWidgetState state;

  static HistoryConfigWidgetState of(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<HistoryConfigInhWidget>()
        ?.widget;
    assert(widget != null, 'HistoryConfigInhWidget was not found in the widget tree');
    return (widget! as HistoryConfigInhWidget).state;
  }

  @override
  bool updateShouldNotify(covariant HistoryConfigInhWidget oldWidget) => false;
}

/// "History" screen: every watched video, newest first, loaded page by page.
class HistoryConfigWidget extends StatefulWidget {
  const HistoryConfigWidget({super.key});

  static Future<void> open(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (context) => const HistoryConfigWidget()),
  );

  @override
  State<HistoryConfigWidget> createState() => HistoryConfigWidgetState();
}

class HistoryConfigWidgetState extends State<HistoryConfigWidget> {
  late final HistoryController historyController;

  @override
  void initState() {
    super.initState();
    historyController = HistoryController(
      historyRepository: HistoryRepositoryImpl(database: DependenciesScope.of(context).database),
    );
    load();
  }

  @override
  void dispose() {
    historyController.dispose();
    super.dispose();
  }

  void load() => historyController.load();

  void paginate() => historyController.paginate();

  @override
  Widget build(BuildContext context) =>
      HistoryConfigInhWidget(state: this, child: const HistoryMobileWidget());
}
