import 'package:youtube/services/authorization_service/authorization_service.dart';

abstract class AuthBlocEvents {}

class LoginEvent extends AuthBlocEvents {

}

class LogoutEvent extends AuthBlocEvents {}

class CheckAuthEvent extends AuthBlocEvents {
  AuthorizationService authorizationService;

  CheckAuthEvent({required this.authorizationService});
}
