import 'package:flutter/material.dart';
import 'package:wolpz/user/create_user.dart';
import 'package:wolpz/user/signin_screen.dart';
import 'package:wolpz/support_files/constants.dart';
import 'package:wolpz/widgets/main_flat_button.dart';

import '../l10n/app_localizations.dart';

class LogInOptionsScreen extends StatefulWidget {
  const LogInOptionsScreen({super.key});

  @override
  State<LogInOptionsScreen> createState() => _LogInOptionsScreenState();
}

class _LogInOptionsScreenState extends State<LogInOptionsScreen> {

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: kDarkBlue,
      body: SafeArea(child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60,),
             const SizedBox(
                  height: 260,
                  child: Image(image: AssetImage('assets/logo_orange.png'))),
              const Spacer(),
              SizedBox(
                width: 260.0,
                height: 60.0,
                child: Semantics(
                  label: localizations.loginTitle,
                  button: true,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      const SigninScreen())),
                  child: MainFlatButton(title: AppLocalizations.of(context)!.loginTitle.toUpperCase(),
                      pressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>
                          const SigninScreen())),
                      background: kBackgroundTint,
                      borderColor: kBackgroundTint,
                      textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: kDarkBlue, fontWeight: FontWeight.bold),

                  ),
                ),
              ),
              const SizedBox(height: 20,),
              SizedBox(
                width: 260.0,
                height: 60.0,
                child: Semantics(
                  label: AppLocalizations.of(context)!.registerButton,
                  button: true,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      const CreateUserScreen())),
                  child: MainFlatButton(title: AppLocalizations.of(context)!.registerButton,
                      pressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>
                          const CreateUserScreen())),
                      background: kDarkOrange,
                      borderColor: kDarkOrange,
                      textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.bold),),
                ),
              ),

            ]
          ),
        ),
      )),
    );
  }
}
