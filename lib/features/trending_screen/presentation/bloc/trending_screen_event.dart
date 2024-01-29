part of 'trending_screen_bloc.dart';

abstract class TrendingScreenEvent extends Equatable {}

class RefreshTrendingScreen extends TrendingScreenEvent {
  @override
  List<Object?> get props => [];
}

class PaginateTrendingScreen extends TrendingScreenEvent {
  @override
  List<Object?> get props => throw UnimplementedError();
}
