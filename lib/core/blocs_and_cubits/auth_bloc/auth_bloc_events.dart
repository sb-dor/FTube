import 'authorization_service/authorization_service.dart';

sealed class AuthBlocEvents {}

final class RegisterEvent extends AuthBlocEvents {}

final class LoginEvent extends AuthBlocEvents {
  AuthorizationService authorizationService;

  LoginEvent({required this.authorizationService});
}

final class LogoutEvent extends AuthBlocEvents {}

final class CheckAuthEvent extends AuthBlocEvents {
  AuthorizationService authorizationService;

  CheckAuthEvent({required this.authorizationService});
}
