part of 'trending_screen_bloc.dart';

abstract class TrendingScreenEvent extends Equatable {}

class RefreshTrendingScreen extends TrendingScreenEvent {
  final VideoCategory category;
  final bool refresh;

  RefreshTrendingScreen({required this.category, this.refresh = false});

  @override
  List<Object?> get props => [category, refresh];
}

