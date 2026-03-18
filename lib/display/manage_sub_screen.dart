import 'dart:io';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wolpz/display/paywall_screen.dart';
import 'package:wolpz/support_files/constants.dart';
import '../l10n/app_localizations.dart';

class ManageSubscriptionScreen extends StatefulWidget {
  const ManageSubscriptionScreen({super.key});

  @override
  State<ManageSubscriptionScreen> createState() => _ManageSubscriptionScreenState();
}

class _ManageSubscriptionScreenState extends State<ManageSubscriptionScreen> {
  bool _isLoading = false;

  Future<void> _onManagePress() async {
    final localizations = AppLocalizations.of(context)!;
    final String error = localizations.connectionErrorAlt;

    final Uri url = Platform.isIOS
        ? Uri.parse("https://apps.apple.com/account/subscriptions")
        : Uri.parse("https://play.google.com/store/account/subscriptions");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw error;
    }
  }

  // Logic to restore past purchases
  Future<void> _onRestorePress() async {
    setState(() => _isLoading = true);
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      bool isPro = customerInfo.entitlements.all["pro_access"]?.isActive ?? false;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isPro ? AppLocalizations.of(context)!.subscriptionRestored
              : AppLocalizations.of(context)!.subscriptionNotFound)),
        );
      }
    } catch (e) {
      debugPrint("Restore Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    final localizations = AppLocalizations.of(context)!;
    final String Function(String url) error = localizations.urlLaunchError;


    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception(error);
      }
    } catch (e) {
      // Just a safety log in case something goes wrong
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundTint,
      appBar: AppBar(
        title:  Text(AppLocalizations.of(context)!.subscriptionManage),
        centerTitle: true,
      ),
      body: FutureBuilder<CustomerInfo>(
        future: Purchases.getCustomerInfo(),
        builder: (context, asyncSnapshot) {
          final isPro = asyncSnapshot.data?.entitlements.all["pro_access"]?.isActive ?? false;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatusBanner(isPro),
                  const Spacer(),
                  if (isPro) ...[
                    SizedBox(
                      height: 60,
                      child: Semantics(
                        label: AppLocalizations.of(context)!.subscriptionManageOrCancel,
                        button: true,
                        onTap: _onManagePress,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kDarkBlue,
                            foregroundColor: kDarkOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          onPressed: _onManagePress,
                          icon: const Icon(Icons.open_in_new, color: kBackgroundTint),
                          label: ExcludeSemantics(
                            child: Text(AppLocalizations.of(context)!.subscriptionManageOrCancel,
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(color: kBackgroundTint)),
                          ),
                        ),
                      ),
                    ),
                     Padding(
                      padding: const  EdgeInsets.only(top: 8.0),
                      child: Text(
                        AppLocalizations.of(context)!.subscriptionManageSettings,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kDarkBlue),
                      ),
                    ),
                  ] else ...[
                    Semantics(
                      label: AppLocalizations.of(context)!.subscriptionUpgrade,
                      button: true,
                      onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const PaywallScreen()),),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kDarkBlue,
                          foregroundColor: kDarkOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const PaywallScreen()),),
                        child:  Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18.0),
                          child:  ExcludeSemantics(
                            child: Text(AppLocalizations.of(context)!.subscriptionUpgrade,
                              style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: kDarkOrange)),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 36),

                  Semantics(
                    label: AppLocalizations.of(context)!.subscriptionRestorePast,
                    button: true,
                    onTap: _isLoading ? null : _onRestorePress,
                    child: OutlinedButton(
                      style: ElevatedButton.styleFrom(
                        side: const BorderSide(color: kDarkBlue, width: 1.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      onPressed: _isLoading ? null : _onRestorePress,
                      child: _isLoading
                          ? const SizedBox(height: 50, width: 50, child: CircularProgressIndicator(strokeWidth: 6))
                          : Padding(
                              padding:  const EdgeInsets.symmetric(vertical: 18.0),
                            child: ExcludeSemantics(
                              child: Text(AppLocalizations.of(context)!.subscriptionRestorePast,
                                  style: Theme.of(context).textTheme.headlineMedium!),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Divider(color: kDarkOrange, thickness: 1.0, indent: 5.0, endIndent:5.0),
                  _buildLegalFooter(),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
  Widget _buildStatusBanner(bool isPro) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: isPro ? Colors.green : kDarkOrange,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isPro ? Icons.check_circle : Icons.warning_amber_rounded, color: isPro ? kBackgroundTint : kBackgroundTint,
          size: 36,),
          const SizedBox(width: 12),
          Text(
            isPro ? AppLocalizations.of(context)!.subscriptionStatusActive :
            AppLocalizations.of(context)!.subscriptionStatusInactive,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: kBackgroundTint),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalFooter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Semantics(
                  label: AppLocalizations.of(context)!.paywallTermsOfUse,
                  button: true,
                  onTap: () => _launchURL('https://www.baaadkitty.uk/wolpz-terms-and-conditions.html'),
                  child: TextButton(onPressed: () => _launchURL('https://www.baaadkitty.uk/wolpz-terms-and-conditions.html'),
                      child:  Container(
                        padding: const EdgeInsets.only(bottom: 2.2),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: kAlertDialogBackground, width: 1.0)),
                        ),
                        child: ExcludeSemantics(
                          child: Text(AppLocalizations.of(context)!.paywallTermsOfUse,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: kAlertDialogBackground,),),
                        ),
                      )),
                ),
                const SizedBox(width: 18, height: 32,
                child: VerticalDivider(color: kAlertDialogBackground, thickness: 1.0, indent: 5.0, endIndent:5.0,),),
                Semantics(
                  label: AppLocalizations.of(context)!.paywallPrivacyPolicy,
                  button: true,
                  onTap: () => _launchURL('https://www.baaadkitty.uk/wolpz-privacy-policy.html'),
                  child: TextButton(onPressed: () => _launchURL('https://www.baaadkitty.uk/wolpz-privacy-policy.html'),
                      child:  Container(
                        padding: const EdgeInsets.only(bottom: 2.2),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: kAlertDialogBackground, width: 1.0)),
                        ),
                        child: ExcludeSemantics(
                          child: Text(AppLocalizations.of(context)!.paywallPrivacyPolicy,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: kAlertDialogBackground,),),
                        ),
                      )),
                ),
              ],
            ),
         Text(AppLocalizations.of(context)!.paywallDisclaimer,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: kDarkBlue),
        ),
      ],
    );
  }
}
