import 'package:youtube/core/utils/hive_database_helper/hive_database_helper.dart';
import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';
import 'package:youtube/features/initialization/logic/composition_root/composition_root.dart';
import 'package:youtube/features/search_screen/bloc/main_search_screen_bloc.dart';
import 'package:youtube/features/search_screen/data/repo/search_screen_repo_impl.dart';
import 'package:youtube/features/search_screen/data/source/suggestion_datasoruce.dart';
import 'package:youtube/features/search_screen/data/source/suggestion_datasource_impl.dart';
import 'package:youtube/features/search_screen/domain/repo/search_screen_repo.dart';

final class SearchScreenBlocFactory implements Factory<MainSearchScreenBloc> {
  final YoutubeDataApi _youtubeDataApi;
  final HiveDatabaseHelper _hiveDatabaseHelper;

  SearchScreenBlocFactory(
    this._youtubeDataApi,
    this._hiveDatabaseHelper,
  );

  @override
  MainSearchScreenBloc create() {
    final SuggestionDatasource restApiGetSuggestionText = SuggestionDatasourceImpl(_youtubeDataApi);

    final SearchScreenRepo searchScreenRepo = SearchScreenRepoImpl(restApiGetSuggestionText);

    return MainSearchScreenBloc(
      screenRepo: searchScreenRepo,
      youtubeDataApi: _youtubeDataApi,
      hiveDatabaseHelper: _hiveDatabaseHelper,
    );
  }
}
