import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:wolpz/data_classes/wolpz_user.dart';
import 'package:wolpz/logic/validator.dart';
import 'package:wolpz/widgets/custom_button.dart';
import 'package:wolpz/widgets/custom_create_user_textfield.dart';

import '../l10n/app_localizations.dart';
import '../logic/device_service.dart';
import '../support_files/constants.dart';
import '../logic/sign_in_core_logic.dart' as auth;

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  late DeviceService deviceService;
  bool _isLoading = false;
  String? _errorMsg;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    deviceService = DeviceService();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<UserCredential?> _createNewUser() async {
    final localizations = AppLocalizations.of(context)!;
    final String notFound = localizations.userNotFound;
    final String wrongPass = localizations.wrongPassword;
    final String notAllowed = localizations.operationNotAllowed;
    final String invalidEmail = localizations.invalidEmail;
    final String disabled = localizations.userDisabled;
    final String weakPass = localizations.weakPassword;
    final String alreadyInUse = localizations.emailAlreadyInUse;
    final String unexpectedError = localizations.unexpectedError;


    if (_isLoading) return null;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      return userCredential;

    } on FirebaseAuthException catch (e) {
      // 3. Handle specific Firebase errors
      String friendlyMessage;
      switch (e.code) {
        case 'user-not-found':
          friendlyMessage = notFound;
          break;
        case 'wrong-password':
        case 'invalid-credential':
          friendlyMessage = wrongPass;
          break;
        case 'operation-not-allowed':
          friendlyMessage = notAllowed;
          break;
        case 'invalid-email':
          friendlyMessage = invalidEmail;
          break;
        case 'user-disabled':
          friendlyMessage = disabled;
          break;
        case 'weak-password':
          friendlyMessage = weakPass;
          break;
        case 'email-already-in-use':
          friendlyMessage = alreadyInUse;
          break;
        default:
          friendlyMessage = unexpectedError;
      }

      setState(() {
        _errorMsg = friendlyMessage;
      });
    } catch (e) {
      setState(() {
        _errorMsg = AppLocalizations.of(context)!.connectionErrorAlt;
      });
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    return null;
  }

  Future<void> _handleOnPressed() async {
    FocusScope.of(context).unfocus();
    setState(() => _isRegistering = true);

    try {
      final UserCredential? userCredential = await _createNewUser();

      if (userCredential != null && userCredential.user != null) {
        final String uid = userCredential.user!.uid;
        await _registerUser(
          uid: uid,
          name: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
        );
        // After 'voicedUser' from Firebase returned
        await Purchases.logIn(uid);
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (mounted) setState(() => _isRegistering = false);
      }
    } catch (error) {
      debugPrint("Error: $error");
      if (mounted) setState(() => _isRegistering = false);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBlue,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 46.0),
        backgroundColor: kDarkBlue,
        title: Text(AppLocalizations.of(context)!.registerTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
        ),
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Form Container
                        Container(
                          decoration: BoxDecoration(
                            color: kDarkOrangeTint,
                            borderRadius: BorderRadius.circular(20),

                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: AutofillGroup(
                              child: Column(
                                children: [
                                  CustomCreateUserField(
                                    label: AppLocalizations.of(context)!.registerFirstNameHint,
                                    controller: _firstNameController,
                                    inputType: TextInputType.name,
                                    autofillHints: const [AutofillHints.givenName],
                                    textInputAction: TextInputAction.next,
                                    isPassword: false,
                                    onChanged: (_) => setState(() => _errorMsg = null),
                                    validator: Validator.validateName, // Changed from validatePassword
                                  ),
                                  CustomCreateUserField(
                                    label: AppLocalizations.of(context)!.registerLastNameHint,
                                    controller: _lastNameController,
                                    inputType: TextInputType.name,
                                    autofillHints: const [AutofillHints.familyName],
                                    textInputAction: TextInputAction.next,
                                    isPassword: false,
                                    onChanged: (_) => setState(() => _errorMsg = null),
                                    validator: Validator.validateName,
                                  ),
                                  CustomCreateUserField(
                                    label: AppLocalizations.of(context)!.registerEmailHint,
                                    controller: _emailController,
                                    inputType: TextInputType.emailAddress,
                                    autofillHints: const [AutofillHints.email],
                                    textInputAction: TextInputAction.next,
                                    isPassword: false,
                                    onChanged: (_) => setState(() => _errorMsg = null),
                                    validator: Validator.validateEmail,
                                  ),
                                  CustomCreateUserField(
                                    label: AppLocalizations.of(context)!.registerPasswordHint,
                                    controller: _passwordController,
                                    inputType: TextInputType.visiblePassword,
                                    autofillHints: const [AutofillHints.newPassword],
                                    textInputAction: TextInputAction.next,
                                    isPassword: true,
                                    onChanged: (_) => setState(() => _errorMsg = null),
                                    validator: Validator.validatePassword,
                                  ),
                                  CustomCreateUserField(
                                    label: AppLocalizations.of(context)!.registerConfirmPasswordHint,
                                    controller: _confirmPasswordController,
                                    inputType: TextInputType.visiblePassword,
                                    autofillHints: const [AutofillHints.newPassword],
                                    textInputAction: TextInputAction.done, // Closes keyboard on last field
                                    isPassword: true,
                                    onChanged: (_) => setState(() => _errorMsg = null),
                                    validator: Validator.validatePassword,
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Error Message Section
                        if (_errorMsg != null) ...[
                          const SizedBox(height: 20),
                          Text(
                            _errorMsg!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: kDarkOrange, fontSize: 24),
                          ),
                        ],
                        const Spacer(),
                        const SizedBox(height: 40),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.45,
                            height: MediaQuery.sizeOf(context).width * 0.45,
                            child: _isRegistering ? Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: kDarkOrange,
                                  borderRadius: BorderRadius.circular(22.0),
                                ),
                                height: MediaQuery.sizeOf(context).width * 0.45,
                                width: MediaQuery.sizeOf(context).width * 0.45,
                                child: const Padding(
                                  padding: EdgeInsets.all(28.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 14.0,
                                  ),
                                ),
                              ),
                            ) : Semantics(
                              label: AppLocalizations.of(context)!.registerButton,
                              button: true,
                              onTap: _handleOnPressed,
                              child: CustomFlatButton(
                                title: AppLocalizations.of(context)!.registerButton,
                                textColor: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                onPressed: _handleOnPressed,
                                color: kDarkOrange,
                                splashColor: kBackgroundTint,
                                borderColor: Colors.transparent,
                                borderWidth: 0.0,
                              ),
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
        ),
      )
    );
  }

  Future<void> _registerUser({
    required String uid,
    required String name,
    required String lastName,
    required String email,

  }) async {
    if (Validator.validateName(name) && Validator.validateEmail(email)) {
      debugPrint('--------------- Registering user');
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        String? deviceId = await deviceService.getUniqueDeviceIdentifier();
        final voicedUser = WolpzUser(
          userID: uid,
          firstName: name,
          lastName: lastName,
          email: email,
          isSubscribed: false,
          registeredDeviceId: deviceId,
          );
        if (mounted) {
          await auth.addUserToFirebase(voicedUser, context);
        }


      } catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    }
  }
}
