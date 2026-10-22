import 'package:youtube/src/common/localization/localization.dart';

/// Home feed categories. Each one is a YouTube search in the user's language, limited to
/// recent uploads so the feed stays fresh.
enum FeedCategory {
  all,
  music,
  gaming,
  movies,
  news,
  sports,
  education,
  technology;

  /// YouTube `sp` filter: videos uploaded this month.
  String get filter => 'EgQIBBAB';

  String label(Localization l10n) => switch (this) {
    all => l10n.feedCategoryAll,
    music => l10n.feedCategoryMusic,
    gaming => l10n.feedCategoryGaming,
    movies => l10n.feedCategoryMovies,
    news => l10n.feedCategoryNews,
    sports => l10n.feedCategorySports,
    education => l10n.feedCategoryEducation,
    technology => l10n.feedCategoryTechnology,
  };

  /// Search query for this category in the current language.
  String query(Localization l10n) => switch (this) {
    all => l10n.feedQueryAll,
    music => l10n.feedQueryMusic,
    gaming => l10n.feedQueryGaming,
    movies => l10n.feedQueryMovies,
    news => l10n.feedQueryNews,
    sports => l10n.feedQuerySports,
    education => l10n.feedQueryEducation,
    technology => l10n.feedQueryTechnology,
  };
}
