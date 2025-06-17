import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';
import 'package:voiced/display/launch_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:voiced/providers/locale_provider.dart';
import 'package:voiced/support_files/constants.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(const Duration(milliseconds: 500));
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    appleProvider: AppleProvider.debug,
  );
  var delegate = await LocalizationDelegate.create(
    fallbackLocale: 'en_GB',
    supportedLocales: ['en_GB', 'fr', 'de', 'es', 'el', 'it', 'hi', 'le'],
    basePath: 'assets/languages/',
  );
  runApp(ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: LocalizedApp(
        delegate, MyApp(localizationDelegate: delegate),
      ),
  ),
  );
}

class MyApp extends StatelessWidget {
  final LocalizationDelegate localizationDelegate;
  const MyApp({super.key, required this.localizationDelegate});

  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ));
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        localizationDelegate,
      ],
      supportedLocales: localizationDelegate.supportedLocales,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.white,
        appBarTheme: const AppBarTheme(
          shadowColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: true,
          color: Colors.white10,
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),
        useMaterial3: false,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(color: kDarkBlue, fontSize: 26, letterSpacing: 0.1, fontFamily: 'Inter', fontWeight: FontWeight.w900),
          displayMedium: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 0.1, fontFamily: 'Inter'),
          bodyMedium: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 0.2, fontFamily: 'Inter'),
        ),
      ),
      home: LaunchScreen(localizationDelegate: localizationDelegate),
    );
  }
}
