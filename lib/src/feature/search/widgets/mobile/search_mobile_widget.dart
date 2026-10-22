import 'package:flutter/material.dart';
import 'package:youtube/src/feature/search/widgets/mobile/search_field_widget.dart';
import 'package:youtube/src/feature/search/widgets/mobile/search_query_list_widget.dart';
import 'package:youtube/src/feature/search/widgets/mobile/search_results_widget.dart';
import 'package:youtube/src/feature/search/widgets/search_config_widget.dart';

class SearchMobileWidget extends StatefulWidget {
  const SearchMobileWidget({super.key});

  @override
  State<SearchMobileWidget> createState() => _SearchMobileWidgetState();
}

class _SearchMobileWidgetState extends State<SearchMobileWidget> {
  late final _scope = SearchConfigInhWidget.of(context);
  late final _dataController = _scope.searchDataController;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _dataController,
    // Back while editing a query returns to the results of the last search.
    builder: (context, child) => PopScope(
      canPop: _dataController.showResults || _dataController.query.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _scope.backToResults();
      },
      child: child!,
    ),
    child: Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        centerTitle: false,
        title: const SearchFieldWidget(),
      ),
      body: ListenableBuilder(
        listenable: _dataController,
        builder: (context, _) => _dataController.showResults
            ? const SearchResultsWidget()
            : const SearchQueryListWidget(),
      ),
    ),
  );
}
