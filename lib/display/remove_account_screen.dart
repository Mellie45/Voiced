import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wolpz/l10n/app_localizations.dart';
import 'package:wolpz/user/login_options_screen.dart';
import 'package:wolpz/logic/sign_in_core_logic.dart' as auth;
import 'package:wolpz/logic/validator.dart';
import 'package:wolpz/widgets/custom_create_user_textfield.dart';
import 'package:wolpz/widgets/custom_login_field.dart';
import 'package:wolpz/widgets/main_flat_button.dart';

import '../support_files/constants.dart';
import 'manage_sub_screen.dart';

class RemoveAccountScreen extends StatefulWidget {
  const RemoveAccountScreen({super.key});

  @override
  State<RemoveAccountScreen> createState() => _RemoveAccountScreenState();
}

class _RemoveAccountScreenState extends State<RemoveAccountScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _deleteAcc() async {
    setState(() => _isLoading = true);

    try {
      await HapticFeedback.vibrate();
      await auth.deleteAccount(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LogInOptionsScreen()),
              (route) => false, // Clears the navigation stack
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.all(16.0),
            duration: const Duration(seconds: 3),
            content: Text(AppLocalizations.of(context)!.removeAccountSuccess),
            backgroundColor: kDarkOrange,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false,);
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundTint,
      appBar: AppBar(),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal:36.0, vertical: 8.0),
        child: Column(
          children: [
            const SizedBox(height: 24.0,),
            Container(
              height: 136.0,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/vocal_eyes_logo.png'),
                      fit: BoxFit.contain)),
            ),
            const SizedBox(height: 24.0,),
            Text(textAlign: TextAlign.center,
                AppLocalizations.of(context)!.removeAccountHeading,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: kDarkBlue)),
            const SizedBox(height: 14.0,),
            Text(
                textAlign: TextAlign.center,
                AppLocalizations.of(context)!.removeAccMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kDarkBlue)),

            Padding(
              padding: const EdgeInsets.only(top: 48.0),
              child: Text(
                  textAlign: TextAlign.center,
                  AppLocalizations.of(context)!.removeAccountHeading,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kDarkOrange, fontWeight: FontWeight.bold)),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                  textAlign: TextAlign.center,
                  AppLocalizations.of(context)!.removeAccMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kDarkBlue)),
            ),
            SizedBox( width: 220.0,
              child: MainFlatButton(
                borderColor: kDarkBlue,
                  title: AppLocalizations.of(context)!.removeAccountCancelBtn,
                  pressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (context) => const ManageSubscriptionScreen(),
                    ),
                    ),
                  background: kDarkBlue, textStyle: kFlatButtonText),
            ),

            const Spacer(),
            SizedBox(width: 220.0,
              child: MainFlatButton(
                borderColor: kDarkOrange,
                  title: AppLocalizations.of(context)!.removeAccountTitle,
                  pressed: (){
                    _showAlertDialogBox();
                  },
                  background: kDarkOrange, textStyle: kFlatButtonText),
            ),
            const SizedBox(height: 8.0,),
          ],
        ),
      )),
    );
  }

  void _showAlertDialogBox() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              backgroundColor: kDarkBlue,
              title: Text(textAlign: TextAlign.center,
                  AppLocalizations.of(context)!.removeAccountTitle,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: kDarkOrange)),
              content: SizedBox(
                height: 300,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CustomCreateUserField(
                        isPassword: false,
                        label: AppLocalizations.of(context)!.registerEmailHint,
                        controller: _emailController,
                        inputType: TextInputType.emailAddress,
                        onChanged: (_) => setState(() {}),
                        validator: Validator.validateEmail,
                      ),
                      const SizedBox(height: 16.0),
                      CustomPasswordField(
                        isPassword: true,
                        iconColor: kDarkOrange,
                        label: AppLocalizations.of(context)!.registerPasswordHint,
                        controller: _passwordController,
                        inputType: TextInputType.visiblePassword,
                        validator: Validator.validatePassword,
                        onChanged: (_) => setState(() {}),
                      ),
                      Text(AppLocalizations.of(context)!.removeAccountConfirm,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: kBackgroundTint),),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.of(context).pop();
                      _emailController.clear();
                      _passwordController.clear();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.selectImageScreenCloseButton.toUpperCase(),
                      style: const TextStyle(color: kBackgroundTint, fontSize: 18.0,),
                    )),
                TextButton(
                    onPressed: _isLoading ? null : _deleteAcc,
                    child: _isLoading ? const SizedBox(height: 50.0, width: 50.0,
                    child: CircularProgressIndicator(color: kDarkOrange, strokeWidth: 2.0,),
                    ) : Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        AppLocalizations.of(context)!.removeAccountConfirmBtn,
                        textAlign: TextAlign.end,
                        style: const TextStyle(color: kDarkOrange, fontSize: 18.0, fontWeight: FontWeight.w800),
                      ),
                    ))
              ],
            );
          });
        });
  }
}
