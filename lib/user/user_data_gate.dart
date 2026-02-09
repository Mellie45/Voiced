import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wolpz/display/launch_screen.dart';
import 'package:wolpz/support_files/constants.dart';
import '../data_classes/voicedUser.dart';
import '../l10n/app_localizations.dart';

class UserDataGate extends StatelessWidget {
  final SharedPreferences prefs;
  const UserDataGate({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    // We "watch" the provider for changes.
    // This will be null at first, then update to a VoicedUser
    final voicedUser = context.watch<VoicedUser?>();
    debugPrint('UserDataGate: build() called. User is: $voicedUser');

    if (voicedUser == null) {
      return Scaffold(
        backgroundColor: kDarkBlue,
        body: SafeArea(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 38.0),
                  child: SizedBox(
                      width: 210,
                      height: 210,
                      child: Image(image: AssetImage('assets/adaptive_eye.png'))),
                ),

                const Padding(
                  padding: EdgeInsets.only(top: 100.0, bottom: 46.0),
                  child: SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(color: kDarkOrange, strokeWidth: 14.0,)),
                ),
                Text(AppLocalizations.of(context)!.loginLoadingProfile, style: kAlertTitleText,),
              ],
            ),
          ),
        ),
      );
    } else {
      return LaunchScreen(user: voicedUser, prefs: prefs,);
    }
  }
}