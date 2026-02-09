import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../logic/route_manager.dart';
import '../support_files/constants.dart';

class PaywallScreen extends StatefulWidget {

  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {

  bool _isLoading = true;
  bool _isPurchasing = false;
  bool _isRestoring = false;
  Offerings? _offerings;
  String? _error;

  final String _entitlementId = 'pro_access';

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
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

  Future<void> _fetchOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        setState(() {
          _offerings = offerings;
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _error = AppLocalizations.of(context)!.paywallGeneralError(e.toString());
      });
    } catch (e) {
      setState(() {
        _error = AppLocalizations.of(context)!.paywallUnexpectedError(e.toString());
      });
      debugPrint("Paywall error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _purchasePackage(Package package) async {
    final localizations = AppLocalizations.of(context)!;
    final String successMsg = localizations.paywallSuccess;
    final String errorMsg = localizations.paywallPurchaseError;

    setState(() {
      _isPurchasing = true;
    });

    try {
      final PurchaseParams purchaseParams = PurchaseParams.package(package);
      final PurchaseResult purchaseResult = await Purchases.purchase(purchaseParams);
      final CustomerInfo customerInfo = purchaseResult.customerInfo;

      // Check if the entitlement is now active
      if (customerInfo.entitlements.active[_entitlementId] != null) {
        await _handleSuccess(successMsg);
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        // Show an error to the user
        if (!context.mounted) return;
        _showErrorToast(errorMsg);
      }
    } catch (e) {
      if (!context.mounted) return;
      _showErrorToast(errorMsg);
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  Future<void> _handleSuccess(String message) async {
    final view = View.of(context);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // 1. TACTILE: Heavy impact confirms the transaction physically
    HapticFeedback.heavyImpact();

    // 2. AUDIO: Force the screen reader to speak immediately
    SemanticsService.sendAnnouncement(
        view, message, TextDirection.ltr, assertiveness: Assertiveness.polite);

    // 3. VISUAL: High-contrast SnackBar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kDarkBlue,
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: kDarkOrange, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  textAlign: TextAlign.center,
                  message,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4. PAUSE: Keep the spinner spinning for 1.5s so they hear/feel the success
    await Future.delayed(const Duration(milliseconds: 1500));

    // 5. NAVIGATION: Now we pop to reveal the unlocked app
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => RouteManager(prefs: prefs)),
            (route) => false, // This removes ALL previous screens from the stack
      );
    }
  }

  Future<void> _restorePurchases() async {
    final localizations = AppLocalizations.of(context)!;
    final String successMsg = localizations.paywallSuccess;
    final String noProductMsg = localizations.paywallNoProducts;
    final String errorMsg = localizations.paywallRestoreError;
    setState(() => _isRestoring = true);
    try {
      final CustomerInfo customerInfo = await Purchases.restorePurchases();

      if (customerInfo.entitlements.active[_entitlementId] != null) {
        await _handleSuccess(successMsg);
      } else {
        if (!context.mounted) return;
        // No active entitlements found
        _showErrorToast(noProductMsg);
      }
    } catch (e) {
      if (!context.mounted) return;
      _showErrorToast(errorMsg);
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }

  void _showErrorToast(String message, {bool isError = true}) {
    if (!context.mounted) return;
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.CENTER,
      backgroundColor: isError ? Colors.red[700] : Colors.green[700],
      textColor: Colors.white,
      fontSize: 18.0,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundTint,
      appBar: AppBar(
        title: Text('', style: Theme.of(context).textTheme.headlineMedium),
        backgroundColor: kBackgroundTint,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final localizations = AppLocalizations.of(context)!;
    final String noProducts = localizations.paywallNoProducts;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_offerings == null || _offerings!.current == null) {
      return  Center(child: Text(noProducts));
    }

    final currentOffering = _offerings!.current!;
    final monthlyPackage = currentOffering.monthly;
    final yearlyPackage = currentOffering.annual;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context)!.paywallHeadline,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.paywallSubHeadline,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: kDarkBlue,
                  fontSize: 16,
                ),
          ),

          const SizedBox(height: 22),

              Text(
                AppLocalizations.of(context)!.paywallMonthlyFlex,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: kDarkBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

          const SizedBox(height: 6.0),
    // --- Monthly Package ---
          if (monthlyPackage != null)
            _buildPackageCard(
              package: monthlyPackage,
              isRecommended: true,
            ),
          const SizedBox(height: 22),
              Text(
                AppLocalizations.of(context)!.paywallYearlySaver,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: kDarkBlue,
                      fontSize: 22,
                  fontWeight: FontWeight.bold,
                    ),
              ),

          const SizedBox(height: 6.0),
          // --- Yearly Package ---
          if (yearlyPackage != null)
            _buildPackageCard(
              package: yearlyPackage,
              isRecommended: false,
            ),

          const SizedBox(height: 34),
          // --- Restore Button ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0),
            child:
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                fixedSize: const Size(double.infinity, 50.0),
                side: const BorderSide(color: kDarkBlue, width: 1.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              onPressed: _isRestoring ? null : _restorePurchases,

                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                    return Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
                  child: _isRestoring
                      ? const Center(
                    key: ValueKey('loading'),
                    child: SizedBox(
                      width: double.infinity,
                      child: LinearProgressIndicator(
                        color: kDarkBlue,
                        minHeight: 6.0,
                      ),
                    ),
                  )
                      : Text(
                    AppLocalizations.of(context)!.paywallRestoreButton,
                    key: const ValueKey('text'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: kDarkBlue,
                      height: 1.0,
                    ),
                  ),
                ),
            ),),
          const SizedBox(height: 12),

          // --- Disclaimer ---
          Text(AppLocalizations.of(context)!.paywallDisclaimer,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                  fontSize: 11,
                ),
          ),
    // --- The Mandatory Links (Apple/Google Requirement) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(

                onPressed: () => _launchURL('https://www.baaadkitty.uk/terms-and-conditions-vocal-eyes.html'),
                child: Text(
                  AppLocalizations.of(context)!.paywallTermsOfUse,
                  style: const TextStyle(fontSize: 11,
                      color: kDarkBlue,
                      decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Text(
                "|",
                style: TextStyle(fontSize: 11, color: kDarkBlue),
              ),
              TextButton(
                onPressed: () => _launchURL('https://www.baaadkitty.uk/terms-and-conditions-vocal-eyes.html'),
                child: Text(
                  AppLocalizations.of(context)!.paywallPrivacyPolicy,
                  style: const TextStyle(fontSize: 11, color: kDarkBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildPackageCard({required Package package, bool isRecommended = false}) {
    final product = package.storeProduct;

    return Card(
      color: isRecommended ? kDarkBlue : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: isRecommended ? BorderSide.none : const BorderSide(color: kDarkBlue, width: 1.0),
      ),
      elevation: 4,
      shadowColor: kDarkBlue,
      child: InkWell(
        onTap: _isPurchasing ? null : () => _purchasePackage(package),
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 28.0),
          child: _isPurchasing
              ? const Center(child: CircularProgressIndicator(color: kDarkBlue))
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      textAlign: TextAlign.center,
                      product.title, // e.g., "Yearly"
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                            color: isRecommended ? kBackgroundTint : kDarkBlue,),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      textAlign: TextAlign.center,
                      product.priceString, // e.g., "$49.99"
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isRecommended ? kDarkOrange : kDarkBlue,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    isRecommended
                        ? Text(
                      textAlign: TextAlign.center,
                      AppLocalizations.of(context)!.paywallMonthlyDescription,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      textAlign: TextAlign.center,
                      AppLocalizations.of(context)!.paywallYearlyDescription,
                      style: const TextStyle(
                        fontSize: 14,
                        color: kDarkBlue,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
