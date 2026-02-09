import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../support_files/constants.dart';
import '../widgets/language_flag_button.dart';

class SetLanguageScreen extends StatefulWidget {
  const SetLanguageScreen({super.key});

  @override
  State<SetLanguageScreen> createState() => _SetLanguageScreenState();
}

class _SetLanguageScreenState extends State<SetLanguageScreen> {

  final Map<String, String> _countryCodes = {
    'en': 'GB',
    'fr': 'FR',
    'de': 'DE',
    'it': 'IT',
    'es': 'ES',
    'el': 'GR',
    'hi': 'IN',
    'ur': 'PK',
  };

  FlagTheme getFlagTheme(Shape shape) {
    return ImageTheme(width: 66, height: 66, shape: shape);
  }

  Future _showLanguageChangeConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: kAlertDialogBackground,
          title: Text(
            AppLocalizations.of(context)!.alertMessagesTitle,
            style: kAlertTitleText.copyWith(fontWeight: FontWeight.w900),
          ),
          content: Text(
            AppLocalizations.of(context)!.alertMessagesBody,
            style: kAlertTitleText,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: const Icon(Icons.check, color: Colors.white),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6.0, top: 60.0),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: kDarkOrange, size: 48.0, ),
                  ),
                ),
              ],
            ),
          ),

           Padding(
            padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
            child: Text(
              maxLines: 2,
              AppLocalizations.of(context)!.languageSelectTitle,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),

          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(46.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 78.0,
                    mainAxisSpacing: 30.0,
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _countryCodes.length,
                  itemBuilder: (context, index) {
                    final languageCode = _countryCodes.keys.elementAt(index);
                    final countryCode = _countryCodes.values.elementAt(index);
                    return LanguageFlagButton(
                      countryCode: countryCode,
                      onTap: () {
                        try {
                          localeProvider.setLocale(Locale(languageCode));
                          Navigator.pop(context);
                              _showLanguageChangeConfirmationDialog(context);

                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(
                                AppLocalizations.of(context)!.languageError(e.toString())
                            )),
                          );
                        }
                      }
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
