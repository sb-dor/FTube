import 'package:youtube/services/authorization_service/authorization_service.dart';

abstract class AuthBlocEvents {}

class RegisterEvent extends AuthBlocEvents {}

class LoginEvent extends AuthBlocEvents {
  AuthorizationService authorizationService;

  LoginEvent({required this.authorizationService});
}

class LogoutEvent extends AuthBlocEvents {}

class CheckAuthEvent extends AuthBlocEvents {
  AuthorizationService authorizationService;

  CheckAuthEvent({required this.authorizationService});
}
