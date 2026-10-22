import 'package:flutter/material.dart';
import 'package:youtube/src/feature/search/widgets/mobile/search_query_item_widget.dart';
import 'package:youtube/src/feature/search/widgets/search_config_widget.dart';

/// While typing: suggestions for the text, or the search history when there are none.
class SearchQueryListWidget extends StatefulWidget {
  const SearchQueryListWidget({super.key});

  @override
  State<SearchQueryListWidget> createState() => _SearchQueryListWidgetState();
}

class _SearchQueryListWidgetState extends State<SearchQueryListWidget> {
  late final _scope = SearchConfigInhWidget.of(context);
  late final _listenable = Listenable.merge([
    _scope.textController,
    _scope.searchSuggestionsController,
    _scope.searchHistoryController,
  ]);

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
    child: ListenableBuilder(
      listenable: _listenable,
      builder: (context, _) {
        final hasText = _scope.textController.text.trim().isNotEmpty;
        final suggestions = hasText
            ? _scope.searchSuggestionsController.state.items
            : const <String>[];
        final isHistory = suggestions.isEmpty;
        final queries = isHistory ? _scope.searchHistoryController.state.items : suggestions;
        return ListView.separated(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(30, 0, 20, 10 + MediaQuery.paddingOf(context).bottom),
          itemCount: queries.length,
          separatorBuilder: (_, _) => const SizedBox(height: 5),
          itemBuilder: (context, index) {
            final query = queries[index];
            return SearchQueryItemWidget(
              key: ValueKey(query),
              query: query,
              onTap: () => _scope.submit(query),
              onDelete: isHistory ? () => _scope.removeFromHistory(query) : null,
            );
          },
        );
      },
    ),
  );
}
