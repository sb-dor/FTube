import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'trending_screen_event.dart';

part 'trending_screen_state.dart';

class TrendingScreenBloc extends Bloc<TrendingScreenEvent, TrendingScreenState> {
  TrendingScreenBloc() : super(TrendingScreenInitial()) {
    on<TrendingScreenEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
