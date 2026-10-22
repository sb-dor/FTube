import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/feature/feed/controller/feed_controller.dart';
import 'package:youtube/src/feature/feed/data/feed_repository.dart';
import 'package:youtube/src/feature/feed/models/feed_category.dart';
import 'package:youtube/src/feature/feed/widgets/controllers/feed_data_controller.dart';
import 'package:youtube/src/feature/feed/widgets/mobile/feed_mobile_widget.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';

/// Provides [FeedConfigWidgetState] to the home feed.
class FeedConfigInhWidget extends InheritedWidget {
  const FeedConfigInhWidget({required this.state, required super.child, super.key});

  final FeedConfigWidgetState state;

  static FeedConfigWidgetState of(BuildContext context) {
    final widget = context.getElementForInheritedWidgetOfExactType<FeedConfigInhWidget>()?.widget;
    assert(widget != null, 'FeedConfigInhWidget was not found in the widget tree');
    return (widget! as FeedConfigInhWidget).state;
  }

  @override
  bool updateShouldNotify(covariant FeedConfigInhWidget oldWidget) => false;
}

/// Home tab: category chips and a paginated list of videos.
class FeedConfigWidget extends StatefulWidget {
  const FeedConfigWidget({super.key});

  @override
  State<FeedConfigWidget> createState() => FeedConfigWidgetState();
}

class FeedConfigWidgetState extends State<FeedConfigWidget> {
  late final FeedController feedController;
  late final FeedDataController feedDataController;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    feedController = FeedController(
      feedRepository: FeedRepositoryImpl(
        youtubeClient: DependenciesScope.of(context).youtubeClient,
      ),
    );
    feedDataController = FeedDataController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The query depends on the language, so the first load waits for Localization.
    if (_loaded) return;
    _loaded = true;
    load();
  }

  @override
  void dispose() {
    feedController.dispose();
    feedDataController.dispose();
    super.dispose();
  }

  FeedCategory get _category => feedDataController.category;

  void load() => feedController.load(
    query: _category.query(Localization.of(context)),
    filter: _category.filter,
  );

  void paginate() => feedController.paginate(
    query: _category.query(Localization.of(context)),
    filter: _category.filter,
  );

  /// Selects [category] and reloads; returns false when it was already selected.
  bool selectCategory(FeedCategory category) {
    if (!feedDataController.select(category)) return false;
    load();
    return true;
  }

  @override
  Widget build(BuildContext context) =>
      FeedConfigInhWidget(state: this, child: const FeedMobileWidget());
}
