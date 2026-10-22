import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';
import 'package:youtube/src/feature/trending/controller/trending_controller.dart';
import 'package:youtube/src/feature/trending/data/trending_repository.dart';
import 'package:youtube/src/feature/trending/models/trending_category.dart';
import 'package:youtube/src/feature/trending/widgets/controllers/trending_data_controller.dart';
import 'package:youtube/src/feature/trending/widgets/mobile/trending_mobile_widget.dart';

/// Provides [TrendingConfigWidgetState] to the trending tab.
class TrendingConfigInhWidget extends InheritedWidget {
  const TrendingConfigInhWidget({required this.state, required super.child, super.key});

  final TrendingConfigWidgetState state;

  static TrendingConfigWidgetState of(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<TrendingConfigInhWidget>()
        ?.widget;
    assert(widget != null, 'TrendingConfigInhWidget was not found in the widget tree');
    return (widget! as TrendingConfigInhWidget).state;
  }

  @override
  bool updateShouldNotify(covariant TrendingConfigInhWidget oldWidget) => false;
}

/// Trending tab: category chips and a paginated list of this week's most viewed videos.
class TrendingConfigWidget extends StatefulWidget {
  const TrendingConfigWidget({super.key});

  @override
  State<TrendingConfigWidget> createState() => TrendingConfigWidgetState();
}

class TrendingConfigWidgetState extends State<TrendingConfigWidget> {
  late final TrendingController trendingController;
  late final TrendingDataController trendingDataController;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    trendingController = TrendingController(
      trendingRepository: TrendingRepositoryImpl(
        youtubeClient: DependenciesScope.of(context).youtubeClient,
      ),
    );
    trendingDataController = TrendingDataController();
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
    trendingController.dispose();
    trendingDataController.dispose();
    super.dispose();
  }

  TrendingCategory get _category => trendingDataController.category;

  void load() => trendingController.load(
    query: _category.query(Localization.of(context)),
    filter: _category.filter,
  );

  void paginate() => trendingController.paginate(
    query: _category.query(Localization.of(context)),
    filter: _category.filter,
  );

  /// Selects [category] and reloads; returns false when it was already selected.
  bool selectCategory(TrendingCategory category) {
    if (!trendingDataController.select(category)) return false;
    load();
    return true;
  }

  @override
  Widget build(BuildContext context) =>
      TrendingConfigInhWidget(state: this, child: const TrendingMobileWidget());
}
