import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../support_files/constants.dart';

class BottomLanguageSheet extends StatefulWidget {
  const BottomLanguageSheet({super.key});

  @override
  State<BottomLanguageSheet> createState() => _BottomLanguageSheetState();
}

class _BottomLanguageSheetState extends State<BottomLanguageSheet> {
  final Map<String, String> _countryCodes = {
    'en-GB': 'GB',
    'fr-FR': 'FR',
    'de-DE': 'DE',
    'it-IT': 'IT',
    'es-ES': 'ES',
    'el-GR': 'GR',
    'hi-IN': 'IN',
    'le-PK': 'PK',
  };

  Future _showLanguageChangeConfirmationDialog(BuildContext context, String selectedLanguage) async {
    changeLocale(context, selectedLanguage);

    return showDialog(
      context: context,
      builder: (context) {
        return Consumer<LocaleProvider>(
          builder: (context, localProvider, child) {
            return AlertDialog(
              contentPadding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              backgroundColor: kAlertDialogBackground,
              title: Text(
                translate('alert_messages.title'),
                style: kAlertTitleText.copyWith(fontWeight: FontWeight.w900),
              ),
              content: Text(
                translate(
                  'alert_messages.body',
                ),
                style: kAlertTitleText,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizationDelegate = LocalizedApp.of(context).delegate;
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final setLocationCode = context.watch<LocaleProvider>();

    return Container(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 10.0),
              Padding(
                padding: const EdgeInsets.only(right: 28.0),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const SizedBox(width: 30.0,
                    height: 30,
                    child: Icon(Icons.close_rounded, color: kDarkOrange, size: 48.0, ),),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              '\nSelect your language',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 7.5,
                mainAxisSpacing: 7.5,
                crossAxisCount: 4,
              ),
              itemCount: _countryCodes.length,
              itemBuilder: (context, index) {
                final languageCode = _countryCodes.keys.elementAt(index);
                final countryCode = languageCode.split('-')[1];
                final codeToPass = languageCode.split('__')[0];
                final code = languageCode.split('-')[0];
                return AspectRatio(
                  aspectRatio: 1.0,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          try {
                            await localizationDelegate.changeLocale(Locale(codeToPass));
                            localeProvider.setLocale(Locale(codeToPass));
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context, '${localeProvider.locale}');
                            String selectedLanguageToDisplay = translate(code);
                              // ignore: use_build_context_synchronously
                              _showLanguageChangeConfirmationDialog(context, selectedLanguageToDisplay);

                            setLocationCode.setLocationCode(code);
                          } catch (e) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error changing language: $e'),
                              ),
                            );
                          }
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 83,
                              height: 83,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(48.0),
                                  color: Colors.white
                              ),

                            ),
                            CountryFlag.fromCountryCode(
                              height: 80,
                              width: 80,
                              countryCode,
                              shape: const Circle(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
