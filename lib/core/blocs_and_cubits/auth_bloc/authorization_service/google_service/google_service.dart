import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:youtube/core/blocs_and_cubits/auth_bloc/authorization_service/authorization_service.dart';
import 'package:youtube/core/utils/extensions.dart';
import 'package:youtube/core/utils/shared_preferences_helper.dart';
import 'package:youtube/core/models/user.dart' as u;

class GoogleService implements AuthorizationService {
  const GoogleService({
    required GoogleSignIn googleSignIn,
    required FirebaseAuth firebaseAuth,
    required SharedPreferencesHelper sharedPreferencesHelper,
  })  : _googleSignIn = googleSignIn,
        _firebaseAuth = firebaseAuth,
        _sharedPreferencesHelper = sharedPreferencesHelper;

  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _firebaseAuth;
  final SharedPreferencesHelper _sharedPreferencesHelper;

  @override
  Future<Map<String, dynamic>> checkAuth() async {
    Map<String, dynamic> res = {};

    try {
      final String? accessToken = _sharedPreferencesHelper.getStringByKey(
        key: 'google_access_token',
      );

      final String? idToken = _sharedPreferencesHelper.getStringByKey(
        key: "google_id_token",
      );

      // debugPrint"access token : $accessToken");
      // debugPrint"idtoken : $idToken");

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final signInWithCredentials = await _firebaseAuth.signInWithCredential(credential);

      final u.User user = u.User(
        id: signInWithCredentials.user?.uid.toInt(),
        name: signInWithCredentials.user?.displayName,
        imageUrl: signInWithCredentials.user?.photoURL,
        email: signInWithCredentials.user?.email,
      );

      res['success'] = true;
      res['user'] = user;
    } catch (e) {
      // debugPrint"checkAuth error is : $e");
      res = await refreshToken();
    }
    return res;
  }

  @override
  Future<Map<String, dynamic>> login() async {
    final Map<String, dynamic> res = {};
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return {"user_popup_dialog": true};

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      await _sharedPreferencesHelper.saveString(
        key: "google_access_token",
        value: googleAuth.accessToken,
      );

      await _sharedPreferencesHelper.saveString(key: "google_id_token", value: googleAuth.idToken);

      final OAuthCredential oAuthCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final signInWithCredentials = await _firebaseAuth.signInWithCredential(oAuthCredential);

      final u.User user = u.User(
        id: signInWithCredentials.user?.uid.toInt(),
        name: signInWithCredentials.user?.displayName,
        imageUrl: signInWithCredentials.user?.photoURL,
        email: signInWithCredentials.user?.email,
      );

      res['success'] = true;
      res['user'] = user;
    } catch (e) {
      res['auth_error'] = true;
      // debugPrint'login error is: $e');
    }
    return res;
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

  Future<Map<String, dynamic>> refreshToken() async {
    if (_firebaseAuth.currentUser != null) {
      final Map<String, dynamic> res = {};
      try {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
        if (googleUser == null) return {"auth_error": true};

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        await _sharedPreferencesHelper.saveString(
          key: "google_access_token",
          value: googleAuth.accessToken,
        );

        await _sharedPreferencesHelper.saveString(
          key: "google_id_token",
          value: googleAuth.idToken,
        );

        res['user'] = u.User(
          id: _firebaseAuth.currentUser?.uid.toInt(),
          name: _firebaseAuth.currentUser?.displayName,
          imageUrl: _firebaseAuth.currentUser?.photoURL,
          email: _firebaseAuth.currentUser?.email,
        );

        res['success'] = true;
      } catch (e) {
        res['auth_error'] = true;
      }
      return res;
    } else {
      return {'auth_error': true};
    }
  }
}
