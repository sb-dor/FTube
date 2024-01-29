import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/blocs_and_cubits/auth_bloc/auth_bloc_events.dart';
import 'package:youtube/core/blocs_and_cubits/auth_bloc/auth_bloc_states.dart';
import 'package:youtube/core/blocs_and_cubits/auth_bloc/auth_state_model/auth_state_model.dart';

class MainAuthBloc extends Bloc<AuthBlocEvents, AuthBlocStates> {
  late AuthStateModel _currentState;

  MainAuthBloc() : super(LoadingAuthState(AuthStateModel())) {
    _currentState = state.authStateModel;

    on<CheckAuthEvent>(
      (event, emit) async => await checkAuth(event, emit),
      transformer: droppable(),
    );

    on<LoginEvent>(
      (event, emit) async => await login(event, emit),
      transformer: droppable(),
    );
  }

  Future<void> checkAuth(CheckAuthEvent event, Emitter<AuthBlocStates> emit) async {
    var data = await event.authorizationService.checkAuth();
    if (data.containsKey("auth_error")) {
      emit(ErrorAuthState(_currentState));
    } else if (data.containsKey("success")) {
      if (data['user'] != null) {
        _currentState.user = data['user'];
        emit(AuthenticatedState(_currentState));
      } else {
        emit(UnAuthenticatedState(_currentState));
      }
    } else {
      emit(ErrorAuthState(_currentState));
    }
  }

  Future<void> login(LoginEvent event, Emitter<AuthBlocStates> emit) async {
    var data = await event.authorizationService.login();
    emit(LoadingAuthState(_currentState));
    if (data.containsKey('user_popup_dialog')) return;
    if (data.containsKey("auth_error")) {
      emit(ErrorAuthState(_currentState));
    } else if (data.containsKey("success")) {
      if (data['user'] != null) {
        _currentState.user = data['user'];
        emit(AuthenticatedState(_currentState));
      } else {
        emit(UnAuthenticatedState(_currentState));
      }
    } else {
      emit(ErrorAuthState(_currentState));
    }
  }
}
