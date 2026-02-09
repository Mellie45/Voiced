import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wolpz/support_files/constants.dart';

import '../l10n/app_localizations.dart';
import '../logic/route_manager.dart';
import '../user/set_language_screen.dart';

class WalkthroughScreen extends StatefulWidget {
  final SharedPreferences prefs;

  const WalkthroughScreen({super.key, required this.prefs
  });

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}


class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hasSavedLanguage = widget.prefs.containsKey('language_code');
      if (!hasSavedLanguage) {
        _showLanguagePicker();
      }
    });
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the grid to breathe
      backgroundColor: kDarkBlue,
      barrierColor: kDarkOrange.withValues(alpha:0.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) => const SetLanguageScreen(),
    );
  }

  void _onIntroEnd(BuildContext context) {
    widget.prefs.setBool('seen', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => RouteManager(
        prefs: widget.prefs,),
      ));
    debugPrint('Shared preferences set to true');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const titleTextStyle = TextStyle(fontSize: 26,
        letterSpacing: 0.6,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w900);
    const bodyStyle = TextStyle(fontSize: 16,
        letterSpacing: 0.1,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400);
    const pageDecoration = PageDecoration(
      titleTextStyle: titleTextStyle,
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.symmetric(horizontal: 16.0),
      pageColor: kDarkBlue,
      imageFlex: 2
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: kDarkBlue,
      globalHeader: SafeArea(child: Align(alignment: Alignment.topRight,
      child: Padding(padding: const EdgeInsets.only(top: 16.0, right: 36.0),
      child: IconButton(
        icon: const Icon(Icons.language, color: kDarkOrange, size: 44.0,),
        onPressed: _showLanguagePicker,
      ),))),
      allowImplicitScrolling: true,
      autoScrollDuration: 4500,
      freeze: true,
      resizeToAvoidBottomInset: true,
      globalFooter: const SizedBox(height: 24.0,),

      pages: [
        PageViewModel(
          title: AppLocalizations.of(context)!.walkthroughTitleHow,
          body: AppLocalizations.of(context)!.walkthroughBodyHow,
          image: Image.asset('assets/allScreens.png', width: width ),
          decoration: pageDecoration,
        ),

        PageViewModel(
    title: AppLocalizations.of(context)!.walkthroughTitleStep1,
    body: AppLocalizations.of(context)!.walkthroughBodyStep1,
          image: Image.asset('assets/screenOne.png', width: width * 0.62,),
          decoration: pageDecoration,
        ),

        PageViewModel(
    title: AppLocalizations.of(context)!.walkthroughTitleStep2,
    body: AppLocalizations.of(context)!.walkthroughBodyStep2,
          image: Image.asset('assets/workingScreens.png', width: width,),
          decoration: pageDecoration,
        ),
        PageViewModel(
        title: AppLocalizations.of(context)!.walkthroughTitleStep3,
    body: AppLocalizations.of(context)!.walkthroughBodyStep3,
          image: Image.asset('assets/app_icon.png'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: true,
      back: const Icon(Icons.arrow_back, color: Colors.white, size: 22,),
      skip:  Text(AppLocalizations.of(context)!.walkthroughSkip, style: Theme.of(context).textTheme.displayMedium),
      next: const Icon(Icons.arrow_forward, color: Colors.white, size: 22,),
      done:  Text(AppLocalizations.of(context)!.walkthroughDone, style: Theme.of(context).textTheme.displayMedium),
      curve: Curves.linearToEaseOut,
      controlsMargin: const EdgeInsets.all(22.0),
      controlsPadding: const EdgeInsets.symmetric(vertical: 12),
      dotsDecorator: const DotsDecorator(
        size: Size(14.0, 14.0),
        color: kDarkBlue,
        activeSize: Size(28.0, 14.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: kDarkOrange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
      ),

    );

  }
}
