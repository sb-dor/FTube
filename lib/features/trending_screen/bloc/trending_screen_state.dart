part of 'trending_screen_bloc.dart';

abstract class TrendingScreenState {
  TrendingStateModel trendingStateModel;

  TrendingScreenState({required this.trendingStateModel});
}

class LoadingTrendingScreenState extends TrendingScreenState {
  LoadingTrendingScreenState(TrendingStateModel trendingStateModel)
      : super(trendingStateModel: trendingStateModel);
}

class ErrorTrendingScreenState extends TrendingScreenState {
  final String message;

  ErrorTrendingScreenState(this.message, TrendingStateModel trendingStateModel)
      : super(trendingStateModel: trendingStateModel);
}

class LoadedTrendingScreenState extends TrendingScreenState {
  LoadedTrendingScreenState(TrendingStateModel trendingStateModel)
      : super(trendingStateModel: trendingStateModel);
}
