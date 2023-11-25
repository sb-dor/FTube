import 'package:youtube/models/user.dart';
import 'package:youtube/services/authorization_service/authorization_service.dart';

class BackendLaravelService implements AuthorizationService {
  @override
  Future<Map<String, dynamic>> checkAuth() {
    // TODO: implement checkAuth
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> login() {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> register() {
    // TODO: implement register
    throw UnimplementedError();
  }
}
