import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:wolpz/logic/validator.dart';
import 'package:wolpz/widgets/custom_button.dart';
import 'package:wolpz/widgets/custom_password_field.dart';
import '../l10n/app_localizations.dart';
import '../support_files/constants.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool loading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final localizations = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);

    final String msgUserNotFound = localizations.userNotFound;
    final String msgWrongPassword = localizations.wrongPassword;
    final String msgOpNotAllowed = localizations.operationNotAllowed;
    final String msgInvalidEmail = localizations.invalidEmail;
    final String msgUserDisabled = localizations.userDisabled;
    final String msgWeakPassword = localizations.weakPassword;
    final String msgEmailInUse = localizations.emailAlreadyInUse;
    final String msgUnexpected = localizations.unexpectedError;
    final String msgConnection = localizations.connectionErrorAlt;

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword (
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final String? uid = userCredential.user?.uid;

      if (uid != null) {
        // 3. Sync with RevenueCat BEFORE navigating away
        await Purchases.logIn(uid);
        navigator.popUntil((route) => route.isFirst);
        debugPrint("RevenueCat: Identified user $uid");
      }

    } on FirebaseAuthException catch (e) {
      // 3. Handle specific Firebase errors
      String friendlyMessage;
      switch (e.code) {
      case 'user-not-found':
      friendlyMessage = msgUserNotFound;
      break;
        case 'wrong-password':
        case 'invalid-credential':
      friendlyMessage = msgWrongPassword;
      break;
      case 'operation-not-allowed':
      friendlyMessage = msgOpNotAllowed;
      break;
      case 'invalid-email':
      friendlyMessage = msgInvalidEmail;
      break;
      case 'user-disabled':
      friendlyMessage = msgUserDisabled;
      break;
      case 'weak-password':
      friendlyMessage = msgWeakPassword;
      break;
      case 'email-already-in-use':
      friendlyMessage = msgEmailInUse;
      break;
      default:
      friendlyMessage = msgUnexpected;
      }

      setState(() {
        _errorMsg = friendlyMessage;
      });
    } catch (e) {
      setState(() {
        _errorMsg = msgConnection;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBlue,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: kDarkBlue,
        centerTitle: true,
        title:  Text(AppLocalizations.of(context)!.loginTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),),
      body: SafeArea(
        child: Stack(
          children: [
            _buildLoginForm(),
          ],
        ),
      ),
    );
  }

  LayoutBuilder _buildLoginForm() {
    return LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = MediaQuery.sizeOf(context).width;
          final double screenHeight = MediaQuery.sizeOf(context).height;

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.05),

                      // Login Form Container
                      Container(
                        decoration: BoxDecoration(
                          color: kDarkOrange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                          child: Column(
                            children: [
                              CustomPasswordField(
                                isPassword: false,
                                label: AppLocalizations.of(context)!.loginEmailHint,
                                controller: _emailController,
                                inputType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                textInputAction: TextInputAction.next,
                                onChanged: (_) => setState(() => _errorMsg = null),
                                validator: Validator.validateEmail,
                              ),
                              const SizedBox(height: 20),
                              CustomPasswordField(
                                isPassword: true,
                                label: AppLocalizations.of(context)!.loginPasswordHint,
                                controller: _passwordController,
                                inputType: TextInputType.text,
                                autofillHints: const [AutofillHints.password],
                                textInputAction: TextInputAction.done,
                                obscureText: true,
                                onChanged: (_) => setState(() => _errorMsg = null),
                                validator: Validator.validatePassword,
                              ),
                              if (_errorMsg != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Text(
                                    _errorMsg!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: kDarkBlue, fontSize: 24),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: 40),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: SizedBox(
                          width: screenWidth * 0.45,
                          height: screenWidth * 0.45,
                          child: _isLoading ?  Center(
                              child: Container(
                                width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: kDarkOrange,
                              borderRadius: BorderRadius.circular(22.0),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(38.0),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 14.0,
                              ),
                            ),
                          )) :
                            CustomFlatButton(
                              title: AppLocalizations.of(context)!.loginButton,
                              textColor: kDarkBlue,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                _handleSignIn();
                              },
                              color: kDarkOrange,
                              splashColor: kBackgroundTint,
                              borderColor: Colors.transparent,
                              borderWidth: 0.0,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
  }
}
