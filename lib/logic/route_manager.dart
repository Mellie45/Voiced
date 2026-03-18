import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wolpz/data_classes/wolpz_user.dart';
import 'package:wolpz/user/login_options_screen.dart';
import 'package:wolpz/logic/sign_in_core_logic.dart';
import 'package:wolpz/user/user_data_gate.dart';

class RouteManager extends StatefulWidget {
  final SharedPreferences prefs;

  const RouteManager({super.key, required this.prefs});

  @override
  State<RouteManager> createState() => _RouteManagerState();
}

class _RouteManagerState extends State<RouteManager> {
  final _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: _firebaseAuth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return StreamProvider<WolpzUser?>(create: (context) => getUser(snapshot.data!.uid),
                initialData: null,
            catchError: (context, error) {
              debugPrint('Provider caught error: $error');
              return null;
            },
            child: UserDataGate(prefs: widget.prefs,));

          } else {
            return const LogInOptionsScreen();
          }
        });
  }
}
