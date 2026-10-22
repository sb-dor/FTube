import 'package:flutter_test/flutter_test.dart';
import 'package:youtube/src/feature/search/models/search_filter.dart';
import 'package:youtube/src/feature/search/widgets/controllers/search_data_controller.dart';

void main() {
  test('the default filter is any-time videos', () {
    expect(const SearchFilter().sp, 'EgIQAQ==');
    expect(SearchDataController().filter, const SearchFilter());
  });

  test('every filter maps to its YouTube sp token', () {
    const expected = {
      SearchResultType.videos: [
        'EgIQAQ==',
        'EgQIARAB',
        'EgQIAhAB',
        'EgQIAxAB',
        'EgQIBBAB',
        'EgQIBRAB',
      ],
      SearchResultType.films: [
        'EgIQBA==',
        'EgQIARAE',
        'EgQIAhAE',
        'EgQIAxAE',
        'EgQIBBAE',
        'EgQIBRAE',
      ],
    };
    for (final type in SearchResultType.values) {
      expect([
        for (final time in SearchUploadTime.values) SearchFilter(uploadTime: time, type: type).sp,
      ], expected[type]);
    }
  });

  test('the data controller returns to the last results only after a search', () {
    final controller = SearchDataController();
    expect(controller.backToResults(), isFalse);
    controller.submit('cats');
    expect(controller.showResults, isTrue);
    controller.edit();
    expect(controller.showResults, isFalse);
    expect(controller.backToResults(), isTrue);
    expect(controller.query, 'cats');
    controller.dispose();
  });
}
