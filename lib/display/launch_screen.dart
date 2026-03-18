import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wolpz/data_classes/wolpz_user.dart';
import 'package:wolpz/support_files/constants.dart';
import 'package:wolpz/widgets/end_drawer.dart';
import '../l10n/app_localizations.dart';
import '../logic/device_service.dart';
import '../logic/image_selection.dart';
import '../providers/locale_provider.dart';
import 'paywall_screen.dart';
import '../widgets/device_limit_dialog.dart';

class LaunchScreen extends StatefulWidget {
  final WolpzUser user;
  final SharedPreferences prefs;

  const LaunchScreen({super.key, required this.user, required this.prefs});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? selectedLanguage;
  String language = ' ';
  bool visible = false;
  String userName = '';
  int remainingUses = 0;
  bool isSubscribed = false;
  bool _isCheckingLimit = false;
  late DeviceService deviceService;


  void setVisibility() async {
    Future.delayed(const Duration(milliseconds: 200)).then((_) {
      setState(() => visible = true);
    });
  }

  void _handleUserData() {
    final user = widget.user;
    setState(() {
      userName = user.firstName;
      remainingUses = user.freeUsesRemaining!;
      widget.prefs.setString('user_first_name', userName);
    });
    debugPrint('The uses remaining for $userName are $remainingUses');

    if (user.isSubscribed) {
      setState(() => isSubscribed = true);
    }
  }

  @override
  void initState() {
    super.initState();
    deviceService = DeviceService();
    setVisibility();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final localProvider = Provider.of<LocaleProvider>(context, listen: false);
      if (localProvider.locationCode.isNotEmpty) {}
    });

    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      final bool updatedStatus = customerInfo.entitlements.all['pro_access']?.isActive ?? false;
      if (updatedStatus != widget.user.isSubscribed) {

        if (mounted) {
          setState(() => isSubscribed = updatedStatus);
          debugPrint("LaunchScreen: Pro status verified with 'pro_access' as $updatedStatus");
        }
      }
    });
  }

  void _handleMainButtonTap() async {
    setState(() => _isCheckingLimit = true);

    try {
      final freshDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.userID)
          .get();

      final freshUser = WolpzUser.fromDocument(freshDoc);

      if (mounted) {
        setState(() {
          remainingUses = freshUser.freeUsesRemaining ?? 0;
          isSubscribed = freshUser.isSubscribed;
        });
      }
      
      final int credits = freshUser.freeUsesRemaining ?? 0;
      // 1.Hardware Limit Check
      bool isDeviceBlocked = await deviceService.hasAlreadyUsedFreeTier();

      await Future.delayed(const Duration(milliseconds: 400));
      if (isDeviceBlocked && !freshUser.isSubscribed && credits <= 0) {
        if (mounted) {
          setState(() => _isCheckingLimit = false);
          showDeviceLimitDialog(context);
        }
        return;
      }
      // 2. Guard: Check Account-level access. If they have a sub or remaining uses, let them through.
      if (freshUser.isSubscribed || credits > 0) {
        debugPrint('======== LaunchScreen: user is subscribed and allowed ========');
        if (mounted) {
          setState(() => _isCheckingLimit = false);
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageSelection(
                user: freshUser,
              ),
            ),
          );
        }
        return;
      }
      // 3. Fallback to Paywall
      if (mounted) {
        setState(() => _isCheckingLimit = false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaywallScreen()),
        );
      }
    } catch (e) {
      debugPrint("Error in button tap: $e");
    } finally {
      // 4. Final Safety: If for any reason we are still on this screen and
      // loading is true, turn it off.
      if (mounted && _isCheckingLimit) {
        setState(() => _isCheckingLimit = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _handleUserData();
    debugPrint('Building LaunchScreen for ${widget.user.firstName}');

    // 1. Grab the value, but treat 'null' as a 'Loading/Initial' state (e.g., 5)
    final int? rawCredits = widget.user.freeUsesRemaining;
    // final int displayCredits = rawCredits ?? 5;

    // 2. Strict check: Only flip to the prompt if we are CERTAIN they have 0
    final bool isExactlyZero = rawCredits != null && rawCredits == 0;
    final bool showSubscriptionPrompt = widget.user.isSubscribed || isExactlyZero;

    final localizations = AppLocalizations.of(context);
    //if (localizations == null) return const Scaffold();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.homeGreeting(userName),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: kDarkBlue),
        ),
      ),
      key: _scaffoldKey,
      endDrawer: EndDrawer(prefs: widget.prefs),
      backgroundColor: kBackgroundTint,
      resizeToAvoidBottomInset: false,
      body: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0, left: 22.0, right: 22.0, bottom: 12.0),
                    child: Container(
                      height: 200,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage('assets/wolpz_full_logo_clear.png'),
                        fit: BoxFit.contain,
                      )),
                    ),
                  ),
                  if (!isSubscribed)
                  showSubscriptionPrompt
                      ? Semantics(
                    label: AppLocalizations.of(context)!.homeScreenSubscriptionPrompt,
                    button: true,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaywallScreen())),
                        child: GestureDetector(
                          excludeFromSemantics: true,
                            child: Text(AppLocalizations.of(context)!.homeScreenSubscriptionPrompt,
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                      color: kDarkBlue,
                                      fontWeight: FontWeight.w900,
                                    )),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const PaywallScreen()));
                            }),
                      )
                      : Text(AppLocalizations.of(context)!.homeScreenFreeUsesRemaining(remainingUses),
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: kDarkOrange,
                                fontWeight: FontWeight.w900,
                              )),
                  const Spacer(),
                  ExcludeSemantics(
                    excluding: !visible,
                    child: AnimatedOpacity(
                      opacity: visible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 600),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Semantics(
                            label: AppLocalizations.of(context)!.homeScreenMainButton,
                            button: true,
                            onTap: _isCheckingLimit ? null : () => _handleMainButtonTap(),
                            child: GestureDetector(
                              onTap: _isCheckingLimit ? null : () => _handleMainButtonTap(),
                              child: Container(
                                width: constraints.maxWidth * 0.75,
                                height: constraints.maxWidth * 0.75,
                                decoration: BoxDecoration(color: kDarkOrange, borderRadius: BorderRadius.circular(22.0)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0, top: 10.0),
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        AppLocalizations.of(context)!.homeScreenMainButton,
                                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: kBackgroundTint),
                                      ),
                                    ),
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: kBackgroundTint,
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Opacity(
                                                opacity: _isCheckingLimit ? 0.0 : 1.0,
                                                child: const Icon(
                                                  Icons.camera_alt_outlined,
                                                  color: kDarkOrange,
                                                  size: 160,
                                                ),
                                              ),
                                              if (_isCheckingLimit)
                                                const SizedBox(
                                                  height: 100.0,
                                                  width: 100.0,
                                                  child: CircularProgressIndicator(
                                                    color: kDarkOrange,
                                                    strokeWidth: 7.0,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
        );
      })),
    );
  }
}
