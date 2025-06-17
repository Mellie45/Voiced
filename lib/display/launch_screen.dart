import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';
import 'package:voiced/support_files/constants.dart';
import '../logic/image_selection.dart';
import '../providers/locale_provider.dart';
import '../widgets/bottom_language_sheet.dart';

class LaunchScreen extends StatefulWidget {
  final LocalizationDelegate localizationDelegate;
  const LaunchScreen({super.key, required this.localizationDelegate});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  String? selectedLanguage;
  String language = ' ';
  bool visible = false;

  void setVisibility() async {
    Future.delayed(const Duration(milliseconds: 200)).then((_) {
      setState(() => visible = true);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
   final localProvider = Provider.of<LocaleProvider>(context, listen: false);
   if (localProvider.locationCode.isNotEmpty) {
     changeLocale(context, localProvider.locationCode);
   }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final localeProvider =
        Provider.of<LocaleProvider>(context, listen: true).locationCode;
    String language = localeProvider.toString();

    if (language.isNotEmpty) {
      changeLocale(context, language);
    }
    setVisibility();
    return Scaffold(
      backgroundColor: kBackgroundTint,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => const BottomLanguageSheet(),
                  backgroundColor: kDarkBlue,
                  barrierColor: kDarkOrange,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22.0),
                    ),
                  ),
                );
              },
              child: SizedBox(
                height: 140,
                child:
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: 2,
                      child: Container(
                        width: width,
                        height: 133,
                        color: kBackgroundTint,
                      ),
                    ),
                    Positioned(
                      top: 52,
                      child: Consumer<LocaleProvider>(
                        builder: (context, localeProvider, child) {
                          return localeProvider.locationCode.isNotEmpty
                              ? SizedBox(
                              height: 56,
                              width: 56,
                              child: CountryFlag.fromLanguageCode(
                                localeProvider.locationCode,
                                shape: const Circle(),
                              )
                          )
                              : const Icon(
                            Icons.add_circle,
                            color: Colors.black,
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 14,
                      child: language == 'en'
                          ? Text('Tap to change language'.toUpperCase(),
                          maxLines: 3,
                          style: kLanguageHeaderText)
                          : Text(translate('home_screen.changed').toUpperCase(),
                        maxLines: 3,
                        style: kLanguageHeaderText,
                      ),
                    )],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 38.0, horizontal: 36.0),
              child: Container(
                height: 138,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage('assets/voicedLogo.webp'),
                  fit: BoxFit.contain,
                )),
              ),
            ),
            const Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedOpacity(
                  opacity: visible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 600),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ImageSelection())),
                    child: Container(
                      width: width * 0.86,
                      height: width * 0.86,
                      decoration: BoxDecoration(
                        color: kDarkOrange,
                        borderRadius: BorderRadius.circular(22.0)
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0, top: 10.0),
                            child: SizedBox(
                              width: width * 0.78,
                                child: Text(
                                  textAlign: TextAlign.center,
                                  translate('home_screen.main_button'),
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: kBackgroundTint),
                                )),
                          ),
                          Container(
                              alignment: Alignment.center,
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(120.0),
                                  color: kBackgroundTint),
                              child: const Icon(Icons.camera_alt_outlined,
                                  color: kDarkOrange, size: 160)),

                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
