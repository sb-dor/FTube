part of 'trending_screen_bloc.dart';

sealed class TrendingScreenState {
  TrendingStateModel trendingStateModel;

  TrendingScreenState({required this.trendingStateModel});
}

final class LoadingTrendingScreenState extends TrendingScreenState {
  LoadingTrendingScreenState(TrendingStateModel trendingStateModel)
      : super(trendingStateModel: trendingStateModel);
}

final class ErrorTrendingScreenState extends TrendingScreenState {
  final String message;

  ErrorTrendingScreenState(this.message, TrendingStateModel trendingStateModel)
      : super(trendingStateModel: trendingStateModel);
}

final class LoadedTrendingScreenState extends TrendingScreenState {
  LoadedTrendingScreenState(TrendingStateModel trendingStateModel)
      : super(trendingStateModel: trendingStateModel);
}
