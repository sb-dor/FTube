import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:youtube/core/blocs_and_cubits/auth_bloc/authorization_service/authorization_service.dart';
import 'package:youtube/models/user.dart' as u;
import 'package:youtube/utils/extensions.dart';
import 'package:youtube/utils/shared_preferences_helper.dart';

class GoogleService implements AuthorizationService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final SharedPreferencesHelper _sharedPreferencesHelper = SharedPreferencesHelper.instance;

  @override
  Future<Map<String, dynamic>> checkAuth() async {
    Map<String, dynamic> res = {};

    try {
      String? accessToken = _sharedPreferencesHelper.getStringByKey(
        key: 'google_access_token',
      );

      String? idToken = _sharedPreferencesHelper.getStringByKey(
        key: "google_id_token",
      );

      debugPrint("access token : $accessToken");
      debugPrint("idtoken : $idToken");

      OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final signInWithCredentials = await _firebaseAuth.signInWithCredential(credential);

      u.User user = u.User(
        id: signInWithCredentials.user?.uid.toInt(),
        name: signInWithCredentials.user?.displayName,
        imageUrl: signInWithCredentials.user?.photoURL,
        email: signInWithCredentials.user?.email,
      );

      res['success'] = true;
      res['user'] = user;
    } catch (e) {
      debugPrint("checkAuth error is : $e");
      res = await refreshToken();
    }
    return res;
  }

  @override
  Future<Map<String, dynamic>> login() async {
    Map<String, dynamic> res = {};
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return {"user_popup_dialog": true};

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      await _sharedPreferencesHelper.saveString(
          key: "google_access_token", value: googleAuth.accessToken);

      await _sharedPreferencesHelper.saveString(key: "google_id_token", value: googleAuth.idToken);

      OAuthCredential oAuthCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final signInWithCredentials = await _firebaseAuth.signInWithCredential(oAuthCredential);

      u.User user = u.User(
        id: signInWithCredentials.user?.uid.toInt(),
        name: signInWithCredentials.user?.displayName,
        imageUrl: signInWithCredentials.user?.photoURL,
        email: signInWithCredentials.user?.email,
      );

      res['success'] = true;
      res['user'] = user;
    } catch (e) {
      res['auth_error'] = true;
      debugPrint('login error is: $e');
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
      Map<String, dynamic> res = {};
      try {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
        if (googleUser == null) return {"auth_error": true};

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        await _sharedPreferencesHelper.saveString(
            key: "google_access_token", value: googleAuth.accessToken);

        await _sharedPreferencesHelper.saveString(
            key: "google_id_token", value: googleAuth.idToken);

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
