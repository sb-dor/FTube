import 'package:youtube/src/common/localization/localization.dart';

/// Trending tab chips. YouTube removed its trending page, so each chip is a search in the user's
/// language for videos uploaded this week, sorted by view count.
enum TrendingCategory {
  now,
  music,
  gaming,
  films;

  /// YouTube `sp` filter: type video, uploaded this week, sorted by view count.
  String get filter => 'CAMSBAgDEAE=';

  String label(Localization l10n) => switch (this) {
    now => l10n.trendingCategoryNow,
    music => l10n.trendingCategoryMusic,
    gaming => l10n.trendingCategoryGaming,
    films => l10n.trendingCategoryFilms,
  };

  /// Search query for this category in the current language.
  String query(Localization l10n) => switch (this) {
    now => l10n.trendingQueryNow,
    music => l10n.trendingQueryMusic,
    gaming => l10n.trendingQueryGaming,
    films => l10n.trendingQueryFilms,
  };
}
