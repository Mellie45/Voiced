
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wolpz/display/walkthrough_screen.dart';
import 'package:wolpz/providers/locale_provider.dart';
import 'package:wolpz/support_files/constants.dart';
import 'package:wolpz/logic/route_manager.dart';
import 'firebase_options.dart';
import 'dart:io' show Platform;
import 'package:wolpz/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = assetManifest.listAssets();
    debugPrint("Modern Assets Found: ${assets.length}");
  } catch (e) {
    debugPrint("CRITICAL: Could not load AssetManifest.json. Error: $e");
  }
  await Future.delayed(const Duration(milliseconds: 500));
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kDebugMode
      ? const AndroidDebugProvider()
    : const AndroidPlayIntegrityProvider(),
    providerApple: kDebugMode
        ? const AppleDebugProvider()
        : const AppleAppAttestProvider(),
  );

  await _configureRevenueCat();
  final prefs = await SharedPreferences.getInstance();
  final String savedLanguageCode = prefs.getString('language_code') ?? 'en';

  runApp(
    ChangeNotifierProvider(
    create: (context) => LocaleProvider(initialLocale: Locale(savedLanguageCode)),
    child: MyApp( prefs: prefs),

  ),
  );
}

// This function initializes RevenueCat with your PRODUCTION keys
Future<void> _configureRevenueCat() async {
  // Use debug logging while we're testing
  await Purchases.setLogLevel(LogLevel.debug);

  PurchasesConfiguration config;
  if (Platform.isAndroid) {
    // --- Paste your Google Play Production key here ---
    config = PurchasesConfiguration("goog_GIhxTzihiFUPgzwoamtHpkDODaO");
  } else if (Platform.isIOS) {
    // --- Paste your Apple Production key here ---
    config = PurchasesConfiguration("appl_frmQUxTVEGKoVkjomrmBlxTOAFt");
  } else {
    return;
  }
  await Purchases.configure(config);
}


class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ));
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return Builder(
          builder: (context) {
            const double maxScaleFactor = 2.0;
            final TextScaler userTextScaler = MediaQuery
                .of(context)
                .textScaler;

            final TextScaler effectiveTextScaler = userTextScaler.clamp(
              minScaleFactor: 1.0, // Ensures text is at least normal size
              maxScaleFactor: maxScaleFactor,
            );

            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: effectiveTextScaler,
              ),
              child: MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,

                // Maintain the user's chosen language
                locale: localeProvider.locale,

                localeListResolutionCallback: (locales, supportedLocales) {
                  return localeProvider.locale;
                },

                debugShowCheckedModeBanner: false,
                title: 'Wolpz',
                theme: ThemeData(
                  primaryColor: Colors.white,
                  appBarTheme: const AppBarTheme(
                    iconTheme: IconThemeData(color: kDarkOrange, size: 46.0),
                    shadowColor: Colors.transparent,
                    elevation: 0.0,
                    centerTitle: true,
                    backgroundColor: kBackgroundTint,
                    titleTextStyle: TextStyle(
                        color: kDarkBlue,
                        fontSize: 20,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w900
                    ),

                  ),
                  useMaterial3: false,
                  textTheme: const TextTheme(
                    headlineMedium: TextStyle(color: kDarkBlue,
                        fontSize: 20,
                        letterSpacing: 0.3,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w900),
                    displayMedium: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 0.1, fontFamily: 'Inter'),
                    bodyMedium: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 0.2, fontFamily: 'Inter'),
                    bodySmall: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 0.2, fontFamily: 'Inter'),
                  ),
                ),
                home: _selection(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _selection() {
    bool seen = (prefs.getBool('seen') ?? false);
    if (seen) {
      return RouteManager(prefs: prefs);
    } else {
      return WalkthroughScreen(prefs: prefs);
    }
  }
}
