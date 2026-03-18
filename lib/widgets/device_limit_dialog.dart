import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../support_files/constants.dart';
import '../display/paywall_screen.dart';
import 'main_flat_button.dart';

void showDeviceLimitDialog(BuildContext context) {
  HapticFeedback.vibrate();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        backgroundColor: kDarkBlue,
        title: Text(
          AppLocalizations.of(context)!.deviceLimitTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: kDarkOrange, fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppLocalizations.of(context)!.deviceLimitMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 16.0),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            children: [
              Semantics(
                label: AppLocalizations.of(context)!.deviceLimitButton,
                button: true,
                onTap: () async {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PaywallScreen()),
                  );
                },
                child: MainFlatButton(
                  title: AppLocalizations.of(context)!.deviceLimitButton,
                  background: kDarkOrange,
                  borderColor: kDarkOrange,
                  textStyle: kFlatButtonText,
                  pressed: () async {
                    Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PaywallScreen()),
                      );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Semantics(
                label: AppLocalizations.of(context)!.selectImageScreenCloseButton,
                button: true,
                onTap: () => Navigator.pop(context),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: ExcludeSemantics(
                    child: Text(
                      AppLocalizations.of(context)!.selectImageScreenCloseButton.toUpperCase(),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}