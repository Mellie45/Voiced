import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../support_files/constants.dart';
import '../widgets/custom_button.dart';

final Uri _url = Uri.parse('https://www.baaadkitty.uk/wolpz.html');

class AboutWolpz extends StatelessWidget {
  const AboutWolpz({super.key});

  Future<void> launchWolpzUrl(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final String urlError = localizations.urlLaunchError(_url.toString());

    if (!await launchUrl(_url)) {
      throw Exception(urlError);
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: kBackgroundTint,
      appBar: AppBar(
        backgroundColor: kBackgroundTint,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 34.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        AppLocalizations.of(context)!.aboutHeader,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: kDarkOrange, fontWeight: FontWeight.w700
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: screenHeight * 0.16,
                        width: screenWidth * 0.5,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/wolpz_full_logo_clear.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        AppLocalizations.of(context)!.aboutDescription,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: kDarkBlue,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        AppLocalizations.of(context)!.aboutLegal,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: kDarkBlue,
                        ),
                      ),
                      Platform.isIOS ? Text(AppLocalizations.of(context)!.iosVoiceInstruction, textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: kDarkBlue,
                        ),)
                      : const SizedBox(),
                      const SizedBox(height: 4.0),
                      // Pushes the button to the bottom if there is space
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: SizedBox(
                          child: Semantics(
                            label: AppLocalizations.of(context)!.aboutVisitSite,
                            button: true,
                            onTap: ()  => launchWolpzUrl(context),
                            child: ExcludeSemantics(
                              child: SizedBox(
                                width: 300,
                                height: 60,
                                child: CustomFlatButton(
                                  title: AppLocalizations.of(context)!.aboutVisitSite,
                                  textColor: kDarkBlue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  onPressed: () => launchWolpzUrl(context),
                                  color: kDarkOrange,
                                  splashColor: kDarkOrangeTint,
                                  borderColor: Colors.transparent,
                                  borderWidth: 0.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

