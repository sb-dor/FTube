import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'playlist_inner_screen_event.dart';
part 'playlist_inner_screen_state.dart';

class PlaylistInnerScreenBloc extends Bloc<PlaylistInnerScreenEvent, PlaylistInnerScreenState> {
  PlaylistInnerScreenBloc() : super(PlaylistInnerScreenInitial()) {
    on<PlaylistInnerScreenEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
