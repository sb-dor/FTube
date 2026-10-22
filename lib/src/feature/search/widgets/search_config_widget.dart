import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/utils/controller_extensions.dart';
import 'package:youtube/src/common/utils/show_message.dart';
import 'package:youtube/src/common/utils/youtube_link.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';
import 'package:youtube/src/feature/search/controller/search_history_controller.dart';
import 'package:youtube/src/feature/search/controller/search_results_controller.dart';
import 'package:youtube/src/feature/search/controller/search_suggestions_controller.dart';
import 'package:youtube/src/feature/search/controller/voice_search_controller.dart';
import 'package:youtube/src/feature/search/data/search_history_repository.dart';
import 'package:youtube/src/feature/search/data/search_repository.dart';
import 'package:youtube/src/feature/search/data/search_suggestions_repository.dart';
import 'package:youtube/src/feature/search/data/voice_search_repository.dart';
import 'package:youtube/src/feature/search/models/voice_search_failure.dart';
import 'package:youtube/src/feature/search/widgets/controllers/search_data_controller.dart';
import 'package:youtube/src/feature/search/widgets/mobile/search_filter_sheet_widget.dart';
import 'package:youtube/src/feature/search/widgets/mobile/search_mobile_widget.dart';
import 'package:youtube/src/feature/search/widgets/mobile/search_voice_dialog_widget.dart';
import 'package:youtube/src/feature/video/widgets/video_config_widget.dart';

/// Provides [SearchConfigWidgetState] to the search screen.
class SearchConfigInhWidget extends InheritedWidget {
  const SearchConfigInhWidget({required this.state, required super.child, super.key});

  final SearchConfigWidgetState state;

  static SearchConfigWidgetState of(BuildContext context) {
    final widget = context.getElementForInheritedWidgetOfExactType<SearchConfigInhWidget>()?.widget;
    assert(widget != null, 'SearchConfigInhWidget was not found in the widget tree');
    return (widget! as SearchConfigInhWidget).state;
  }

  @override
  bool updateShouldNotify(covariant SearchConfigInhWidget oldWidget) => false;
}

/// Search screen: animated search field, suggestions and history while typing, voice search,
/// filters and paginated results.
class SearchConfigWidget extends StatefulWidget {
  const SearchConfigWidget({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SearchConfigWidget()));

  @override
  State<SearchConfigWidget> createState() => SearchConfigWidgetState();
}

class SearchConfigWidgetState extends State<SearchConfigWidget> {
  late final SearchResultsController searchResultsController;
  late final SearchSuggestionsController searchSuggestionsController;
  late final SearchHistoryController searchHistoryController;
  late final VoiceSearchController voiceSearchController;
  late final SearchDataController searchDataController;
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final dependencies = DependenciesScope.of(context);
    searchResultsController = SearchResultsController(
      searchRepository: SearchRepositoryImpl(youtubeClient: dependencies.youtubeClient),
    );
    searchSuggestionsController = SearchSuggestionsController(
      suggestionsRepository: SearchSuggestionsRepositoryImpl(
        youtubeClient: dependencies.youtubeClient,
      ),
    );
    searchHistoryController = SearchHistoryController(
      historyRepository: SearchHistoryRepositoryImpl(
        sharedPreferences: dependencies.sharedPreferences,
      ),
    )..load();
    voiceSearchController = VoiceSearchController(
      voiceSearchRepository: VoiceSearchRepositoryImpl(),
    )..addListener(_onVoiceSearchChanged);
    searchDataController = SearchDataController();
  }

  @override
  void dispose() {
    voiceSearchController
      ..removeListener(_onVoiceSearchChanged)
      ..dispose();
    searchResultsController.dispose();
    searchSuggestionsController.dispose();
    searchHistoryController.dispose();
    searchDataController.dispose();
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  /// The user typed: show suggestions for the new text.
  void onTextChanged(String text) {
    searchDataController.edit();
    searchSuggestionsController.request(text);
  }

  /// The user tapped the field while results were shown: go back to typing.
  void onFieldTap() {
    if (!searchDataController.showResults) return;
    searchDataController.edit();
    searchSuggestionsController.request(textController.text);
  }

  /// Searches for [text]; a YouTube link opens that video instead.
  void submit(String text) {
    final query = text.trim();
    if (query.isEmpty) return;
    _setText(query);
    focusNode.unfocus();
    final videoId = _videoIdInText(query);
    if (videoId != null) {
      VideoConfigWidget.openById(context, videoId: videoId).ignore();
      return;
    }
    searchHistoryController.add(query);
    searchDataController.submit(query);
    load();
  }

  void load() => searchResultsController.load(
    query: searchDataController.query,
    filter: searchDataController.filter.sp,
  );

  void paginate() => searchResultsController.paginate(
    query: searchDataController.query,
    filter: searchDataController.filter.sp,
  );

  void clearText() {
    textController.clear();
    searchSuggestionsController.clear();
    searchDataController.edit();
    focusNode.requestFocus();
  }

  void removeFromHistory(String query) => searchHistoryController.remove(query);

  /// Leaves the typing list for the results of the last search; false when there are none.
  bool backToResults() {
    if (!searchDataController.backToResults()) return false;
    _setText(searchDataController.query);
    focusNode.unfocus();
    return true;
  }

  /// Opens the filter sheet; applying it runs the search again.
  Future<void> openFilter() async {
    final filter = await SearchFilterSheetWidget.show(context, filter: searchDataController.filter);
    if (filter == null || !mounted) return;
    searchDataController.setFilter(filter);
    if (searchDataController.query.isNotEmpty) load();
  }

  /// Listens to the microphone in a dialog and searches for what was said.
  Future<void> startVoiceSearch() async {
    focusNode.unfocus();
    voiceSearchController.start();
    await SearchVoiceDialogWidget.show(context, controller: voiceSearchController);
    // Closing the dialog early ("Finish", back, tap outside) ends listening with the words so far.
    voiceSearchController.stop();
    await voiceSearchController.waitFor((state) => state is! VoiceSearch$ListeningState);
    if (!mounted) return;
    final l10n = Localization.of(context);
    switch (voiceSearchController.state) {
      case VoiceSearch$CompletedState(:final words) when words.isNotEmpty:
        submit(words);
      case VoiceSearch$CompletedState():
        showMessage(context, message: l10n.searchVoiceNothingHeard);
      case VoiceSearch$ErrorState(:final failure):
        showMessage(
          context,
          isError: true,
          message: switch (failure) {
            VoiceSearchFailure.permissionDenied => l10n.searchVoicePermissionDenied,
            VoiceSearchFailure.unavailable => l10n.searchVoiceUnavailable,
            VoiceSearchFailure.failed => l10n.searchVoiceFailed,
          },
        );
      case VoiceSearch$InitialState() || VoiceSearch$ListeningState():
        break;
    }
  }

  /// Types the words recognized so far into the field.
  void _onVoiceSearchChanged() {
    if (voiceSearchController.state case VoiceSearch$ListeningState(:final words)
        when words.isNotEmpty) {
      _setText(words);
    }
  }

  void _setText(String text) {
    if (textController.text == text) return;
    textController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  /// The id of a YouTube video linked in [text]. Only link-like words count, so an ordinary
  /// 11-letter query such as "programming" is never mistaken for a bare video id.
  static String? _videoIdInText(String text) {
    for (final word in text.split(RegExp(r'\s+'))) {
      if (!word.toLowerCase().contains('youtu')) continue;
      final id = videoIdFromLink(word);
      if (id != null) return id;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) =>
      SearchConfigInhWidget(state: this, child: const SearchMobileWidget());
}
