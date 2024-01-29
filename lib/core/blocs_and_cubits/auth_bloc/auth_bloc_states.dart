import 'package:youtube/core/blocs_and_cubits/auth_bloc/auth_state_model/auth_state_model.dart';

abstract class AuthBlocStates {
  AuthStateModel authStateModel;

  AuthBlocStates({required this.authStateModel});
}

class LoadingAuthState extends AuthBlocStates {
  LoadingAuthState(AuthStateModel authStateModel) : super(authStateModel: authStateModel);
}

class ErrorAuthState extends AuthBlocStates {
  ErrorAuthState(AuthStateModel authStateModel) : super(authStateModel: authStateModel);
}

class UnAuthenticatedState extends AuthBlocStates {
  UnAuthenticatedState(AuthStateModel authStateModel) : super(authStateModel: authStateModel);
}

class AuthenticatedState extends AuthBlocStates {
  AuthenticatedState(AuthStateModel authStateModel) : super(authStateModel: authStateModel);
}
