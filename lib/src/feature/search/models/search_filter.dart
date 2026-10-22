import 'package:flutter/foundation.dart';
import 'package:youtube/src/common/localization/localization.dart';

/// Upload-date limit of a search.
enum SearchUploadTime {
  any,
  lastHour,
  today,
  thisWeek,
  thisMonth,
  thisYear;

  String label(Localization l10n) => switch (this) {
    any => l10n.searchFilterAnyTime,
    lastHour => l10n.searchFilterLastHour,
    today => l10n.searchFilterToday,
    thisWeek => l10n.searchFilterThisWeek,
    thisMonth => l10n.searchFilterThisMonth,
    thisYear => l10n.searchFilterThisYear,
  };
}

/// Kind of results a search returns.
enum SearchResultType {
  videos,
  films;

  String label(Localization l10n) => switch (this) {
    videos => l10n.searchFilterVideos,
    films => l10n.searchFilterFilms,
  };
}

/// Search filter chosen in the filter sheet.
@immutable
class SearchFilter {
  const SearchFilter({this.uploadTime = SearchUploadTime.any, this.type = SearchResultType.videos});

  final SearchUploadTime uploadTime;
  final SearchResultType type;

  /// YouTube `sp` search parameter for this filter.
  String get sp => switch ((type, uploadTime)) {
    (SearchResultType.videos, SearchUploadTime.any) => 'EgIQAQ==',
    (SearchResultType.videos, SearchUploadTime.lastHour) => 'EgQIARAB',
    (SearchResultType.videos, SearchUploadTime.today) => 'EgQIAhAB',
    (SearchResultType.videos, SearchUploadTime.thisWeek) => 'EgQIAxAB',
    (SearchResultType.videos, SearchUploadTime.thisMonth) => 'EgQIBBAB',
    (SearchResultType.videos, SearchUploadTime.thisYear) => 'EgQIBRAB',
    (SearchResultType.films, SearchUploadTime.any) => 'EgIQBA==',
    (SearchResultType.films, SearchUploadTime.lastHour) => 'EgQIARAE',
    (SearchResultType.films, SearchUploadTime.today) => 'EgQIAhAE',
    (SearchResultType.films, SearchUploadTime.thisWeek) => 'EgQIAxAE',
    (SearchResultType.films, SearchUploadTime.thisMonth) => 'EgQIBBAE',
    (SearchResultType.films, SearchUploadTime.thisYear) => 'EgQIBRAE',
  };

  SearchFilter copyWith({SearchUploadTime? uploadTime, SearchResultType? type}) =>
      SearchFilter(uploadTime: uploadTime ?? this.uploadTime, type: type ?? this.type);

  @override
  bool operator ==(Object other) =>
      other is SearchFilter && other.uploadTime == uploadTime && other.type == type;

  @override
  int get hashCode => Object.hash(uploadTime, type);
}
