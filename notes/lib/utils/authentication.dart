// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  // Initializing Firebase for google sign in authentication
  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    await Firebase.initializeApp();
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            Authentication.customSnackBar(
                content:
                    'The account already exists with a different credential.'),
          );
        } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(Authentication.customSnackBar(
              content:
                  'Error occurred while accessing credentials. Please try again.'));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            Authentication.customSnackBar(
                content:
                    'Error occurred using Google Sign-In. Please try again.'));
      }
    }

    return user;
  }

  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
        backgroundColor: Colors.black,
        content: Text(
          content,
          style: const TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
        ));
  }
}
