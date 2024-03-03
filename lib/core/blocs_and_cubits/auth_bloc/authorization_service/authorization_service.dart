
abstract class AuthorizationService {
  Future<Map<String, dynamic>> login();

  Future<Map<String, dynamic>> logout();

  Future<Map<String, dynamic>> register();

  Future<Map<String, dynamic>> checkAuth();
}
