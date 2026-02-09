import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wolpz/data_classes/voicedUser.dart';
import 'package:wolpz/support_files/constants.dart';

import '../l10n/app_localizations.dart';

Future<UserCredential?> createAccount(String email, String password) async {
  try {
    final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      debugPrint('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      debugPrint('The account already exists for that email.');
    } else {
      debugPrint(e.message);
    }
    return null;
  }
}

Future<void> addUserToFirebase(VoicedUser user, BuildContext context) async {
  try {
    final bool onValue = await checkUserExist(user.userID);
    debugPrint('---------- addUser called');

    if(!onValue) {
      await FirebaseFirestore.instance.collection('users').doc(user.userID).set(user.toJson());
    } else {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)?.emailAlreadyInUse ?? 'Email already in use',
        gravity: ToastGravity.CENTER,
        backgroundColor: kDarkBlue,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
      debugPrint("user ${user.firstName} ${user.email} exists");
    }

  } catch (e) {
    debugPrint('Error in addUserToFirebase: $e');
    throw Exception('Failed to add user to database.');
  }
  }

Stream<VoicedUser?> getUser(String userID) {
  return FirebaseFirestore.instance.collection('users').doc(userID).snapshots()
      .map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          try {
            final Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
            return VoicedUser.fromJson(data);
          } catch (e) {
            debugPrint('Error in getUser: $e');
            return null;
          }

        } else {
          return null;
        }
  });
}

Future<UserCredential?> signIn(String email, String password) async {
    // This signs in the user
    final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return userCredential;

}

Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}

Future<bool> checkUserExist(String userID) async {
  bool exists = false;
  try {
    await FirebaseFirestore.instance.doc("users/$userID").get().then((doc) {
      if (doc.exists) {
        exists = true;
      } else {
        exists = false;
      }
    });
    return exists;
  } catch (e) {
    debugPrint('firebase_user_management error: checkUserExists has failed');
    return false;
  }
}

Future<void> deleteAccount(String email, String password) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  User? user = auth.currentUser;

  if (user == null) throw Exception("No user logged in");

  // 1. Re-authenticate (Crucial for sensitive operations)
  AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
  await user.reauthenticateWithCredential(credential);

  // 2. Delete Firestore Data first (while Auth still exists)
  DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  await docRef.delete();

  // 3. Delete Auth User
  await user.delete();
}
