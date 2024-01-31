part of 'trending_screen_bloc.dart';

abstract class TrendingScreenEvent extends Equatable {}

class RefreshTrendingScreen extends TrendingScreenEvent {
  final VideoCategory category;

  RefreshTrendingScreen({required this.category});

  @override
  List<Object?> get props => [category];
}

