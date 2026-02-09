import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wolpz/display/remove_account_screen.dart';
import 'package:wolpz/support_files/constants.dart';
import 'package:wolpz/widgets/main_flat_button.dart';
import '../l10n/app_localizations.dart';
import '../support_files/support_email.dart';

final Uri _url = Uri.parse('https://www.baaadkitty.uk/terms-and-conditions-vocal-eyes.html');

class TermsAndPrivacyScreen extends StatelessWidget {
  final SharedPreferences prefs;
  const TermsAndPrivacyScreen({super.key, required this.prefs});

  Future<void> launchWolpzUrl(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final String urlError = localizations.urlLaunchError(_url.toString());

    if (!await launchUrl(_url)) {
      throw Exception(urlError);
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    String userName = prefs.getString('user_first_name') ?? 'User';
    return Scaffold(
      backgroundColor: kDarkBlue,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: kDarkBlue,
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.termsAndPrivacyTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: kBackgroundTint)),
      ),
      body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 22.0,),
                  Text(
                      textAlign: TextAlign.center,
                      AppLocalizations.of(context)!.termsAndPrivacyGreeting(userName),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: kBackgroundTint)),
                  const SizedBox(height: 22.0,),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: MainFlatButton(
                        title: AppLocalizations.of(context)!.termsVisitButton.toUpperCase(),
                        pressed: () => launchWolpzUrl(context),
                        background: kDarkBlue,
                      borderColor: kDarkOrange,
                        textStyle: kOrangeButtonText,
                    ),
                  ),
                  const SizedBox(height: 42.0,),
                  Text(
                      textAlign: TextAlign.center,
                      AppLocalizations.of(context)!.termsEmailPrompt,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: kBackgroundTint)),
                  const SizedBox(height: 22.0,),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: MainFlatButton(
                      title: AppLocalizations.of(context)!.termsEmailButton.toUpperCase(),
                      pressed: () => sendSupportEmail(context),
                      background: kDarkBlue,
                      borderColor: kDarkOrange,
                      textStyle: kOrangeButtonText,
                    ),
                  ),

                  const Spacer(),
                  GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const RemoveAccountScreen(),
                      ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 2.2),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: kBackgroundTint, width: 1.0)),
                        ),
                        child: Text(
                            AppLocalizations.of(context)!.termsRemoveLink,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: kBackgroundTint,),),
                      ),),

                  const SizedBox(height: 32.0,)
                    ],
              ),
            ),
          )),
    );
  }
}
