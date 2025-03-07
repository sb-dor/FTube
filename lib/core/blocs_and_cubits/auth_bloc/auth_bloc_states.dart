import 'package:youtube/core/blocs_and_cubits/auth_bloc/auth_state_model/auth_state_model.dart';

abstract class AuthBlocStates {
  AuthStateModel authStateModel;

  AuthBlocStates({required this.authStateModel});
}

final class LoadingAuthState extends AuthBlocStates {
  LoadingAuthState(AuthStateModel authStateModel) : super(authStateModel: authStateModel);
}

final class ErrorAuthState extends AuthBlocStates {
  ErrorAuthState(AuthStateModel authStateModel) : super(authStateModel: authStateModel);
}

final class UnAuthenticatedState extends AuthBlocStates {
  UnAuthenticatedState(AuthStateModel authStateModel) : super(authStateModel: authStateModel);
}

final class AuthenticatedState extends AuthBlocStates {
  AuthenticatedState(AuthStateModel authStateModel) : super(authStateModel: authStateModel);
}
