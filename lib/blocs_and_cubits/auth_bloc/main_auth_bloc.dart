import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/blocs_and_cubits/auth_bloc/auth_bloc_events.dart';
import 'package:youtube/blocs_and_cubits/auth_bloc/auth_bloc_states.dart';
import 'package:youtube/blocs_and_cubits/auth_bloc/auth_state_model/auth_state_model.dart';

class MainAuthBloc extends Bloc<AuthBlocEvents, AuthBlocStates> {
  late AuthStateModel currentState;

  MainAuthBloc() : super(LoadingAuthState(AuthStateModel())) {
    currentState = state.authStateModel;

    on<CheckAuthEvent>((event, emit) async => checkAuth(event, emit), transformer: droppable());
  }

  Future<void> checkAuth(CheckAuthEvent event, Emitter<AuthBlocStates> emit) async {
    var data = await event.authorizationService.checkAuth();
    if (data.containsKey("auth_error")) {
      emit(ErrorAuthState(currentState));
    } else if (data.containsKey("success")) {
      if (data['user'] != null) {
        currentState.user = data['user'];
        emit(AuthenticatedState(currentState));
      } else {
        emit(UnAuthenticatedState(currentState));
      }
    } else {
      emit(ErrorAuthState(currentState));
    }
  }
}
