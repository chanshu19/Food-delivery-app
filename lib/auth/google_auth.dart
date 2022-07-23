// function to implement the google signin

// creating firebase instance

// ignore_for_file: prefer_const_constructors

// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tomato/screens/home.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

Future<void> googleSignup(BuildContext context) async {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
  if (googleSignInAccount != null) {
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    final AuthCredential authCredential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    // Getting users credential
    UserCredential result = await auth.signInWithCredential(authCredential);
    User? user = result.user;
    // debugPrint(user!.email);
    final db = FirebaseFirestore.instance;
    await db.collection('/Users').doc(user!.uid).set({
      "name": user.displayName,
      "email": user.email,
      "photo": user.photoURL,
      "deliveryAddress": "none",
      "phone": "none",
    }).whenComplete(() => Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Home(0))));
  }
}

//  log out
Future<void> googleSignOut(BuildContext context) async {
  await GoogleSignIn().disconnect();
  auth.signOut();
}
