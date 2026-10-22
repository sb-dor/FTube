import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/feature/search/models/search_filter.dart';
import 'package:youtube/src/feature/search/widgets/mobile/search_filter_radio_widget.dart';

/// "Filter" sheet: upload time and result type. Returns the applied filter, or null when the
/// sheet was dismissed without applying.
class SearchFilterSheetWidget extends StatefulWidget {
  const SearchFilterSheetWidget({required this.filter, required this.scrollController, super.key});

  static Future<SearchFilter?> show(BuildContext context, {required SearchFilter filter}) =>
      showModalBottomSheet<SearchFilter>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.96,
          maxChildSize: 0.96,
          expand: false,
          builder: (context, scrollController) =>
              SearchFilterSheetWidget(filter: filter, scrollController: scrollController),
        ),
      );

  final SearchFilter filter;
  final ScrollController scrollController;

  @override
  State<SearchFilterSheetWidget> createState() => _SearchFilterSheetWidgetState();
}

class _SearchFilterSheetWidgetState extends State<SearchFilterSheetWidget> {
  late SearchFilter _filter = widget.filter;

  static const _sectionStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.9,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        tooltip: l10n.searchFilterApply,
        onPressed: () => Navigator.pop(context, _filter),
        child: const Icon(Icons.search, color: Colors.white),
      ),
      appBar: AppBar(
        title: Text(l10n.searchFilterTitle),
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 100),
        children: [
          Text(l10n.searchFilterOrderByTime, style: _sectionStyle),
          const SizedBox(height: 5),
          for (final time in SearchUploadTime.values)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 3),
              child: SearchFilterRadioWidget(
                label: time.label(l10n),
                selected: _filter.uploadTime == time,
                onTap: () => setState(() => _filter = _filter.copyWith(uploadTime: time)),
              ),
            ),
          const SizedBox(height: 20),
          Text(l10n.searchFilterOrderByType, style: _sectionStyle),
          const SizedBox(height: 5),
          for (final type in SearchResultType.values)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 3),
              child: SearchFilterRadioWidget(
                label: type.label(l10n),
                selected: _filter.type == type,
                onTap: () => setState(() => _filter = _filter.copyWith(type: type)),
              ),
            ),
        ],
      ),
    );
  }
}
