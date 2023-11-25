import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:youtube/models/user.dart' as u;
import 'package:youtube/services/authorization_service/authorization_service.dart';
import 'package:youtube/utils/extensions.dart';
import 'package:youtube/utils/shared_preferences_helper.dart';

class GoogleService implements AuthorizationService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Future<Map<String, dynamic>> checkAuth() async {
    Map<String, dynamic> res = {};

    try {
      String? accessToken = SharedPreferencesHelper.instance.getStringByKey(
        key: 'google_access_token',
      );

      String? idToken = SharedPreferencesHelper.instance.getStringByKey(
        key: "google_id_token",
      );

      OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final signInWithCredentials = await FirebaseAuth.instance.signInWithCredential(credential);

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
      res['auth_error'] = true;
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

      await SharedPreferencesHelper.instance
          .saveString(key: "google_access_token", value: googleAuth.accessToken);

      await SharedPreferencesHelper.instance
          .saveString(key: "google_id_token", value: googleAuth.idToken);

      OAuthCredential oAuthCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final signInWithCredentials =
          await FirebaseAuth.instance.signInWithCredential(oAuthCredential);

      u.User user = u.User(
        id: signInWithCredentials.user?.uid.toInt(),
        name: signInWithCredentials.user?.displayName,
        imageUrl: signInWithCredentials.user?.photoURL,
        email: signInWithCredentials.user?.email,
      );

      res['success'] = true;
      res['user'] = user;
    } catch (e) {}
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
}
