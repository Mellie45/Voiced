import 'package:flutter/material.dart';
import 'package:wolpz/display/about_wolpz.dart';
import 'package:wolpz/display/manage_sub_screen.dart';
import 'package:wolpz/display/remove_account_screen.dart';
import 'package:wolpz/display/terms_and_privacy_screen.dart';
import 'package:wolpz/display/walkthrough_screen.dart';
import 'package:wolpz/support_files/share_app_option.dart';
import '../l10n/app_localizations.dart';
import '../support_files/constants.dart';
import '../logic/sign_in_core_logic.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../support_files/support_email.dart';
import '../user/set_language_screen.dart';


class EndDrawer extends StatefulWidget {
  final SharedPreferences prefs;
  const EndDrawer({super.key, required this.prefs});

  @override
  State<EndDrawer> createState() => _EndDrawerState();
}

class _EndDrawerState extends State<EndDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      shadowColor: Colors.transparent,
      backgroundColor: kDarkOrange,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
                padding: EdgeInsets.zero,
                 children: [
                  _buildDrawerHeader(context),
                  _buildDrawerItems(context),
                ]
            ),
          ),
          const Divider( color: kDarkBlue, thickness: 1.0, indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0, top: 8.0),
            child: Text(

              //TODO: Update this with EVERY release
              'Wolpz Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: kDarkBlue,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kBackgroundTint, width: 1.0)),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: Text(AppLocalizations.of(context)!.drawerYourWolpz, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: kBackgroundTint),),
              ),
               IconButton(
                 icon: const Icon(Icons.close_outlined, color: kBackgroundTint, size: 30,),
                 onPressed: () => Navigator.of(context).pop(),),
            ],
          ),
          //const SizedBox(height: 8.0,),
          Container(
            width: 160,
            height: 74.0,
            decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/adaptive_eye.png'),
                  fit: BoxFit.cover,
                ),
            ),
          ),

        ],
      ),);

  }

  Widget _buildDrawerItems(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ListTile(
            dense: true,
            minLeadingWidth: 20,
            leading: const ExcludeSemantics(
              child: Icon(
                Icons.info_rounded,
                size: 30,
                color: kDarkBlue,
              ),
            ),
            title: Text(AppLocalizations.of(context)!.drawerAbout, style: Theme.of(context).textTheme.bodyMedium,),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => const AboutWolpz(),
              ),
              );
            },
          ),

          ListTile(
            leading: const ExcludeSemantics(child: const Icon(Icons.language, color: kDarkBlue, size: 30,)),
            title: Text(AppLocalizations.of(context)!.drawerLanguage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onTap: () {
              Navigator.pop(context);

              // Open your existing language sheet
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: kDarkBlue,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
                ),
                builder: (context) => const SetLanguageScreen(),
              );
            },
          ),

          ListTile(
            dense: true,
            minLeadingWidth: 20,
            leading: const ExcludeSemantics(
              child: Icon(
                Icons.credit_card_off_outlined,
                size: 30,
                color: kDarkBlue,
              ),
            ),
            title: Text(AppLocalizations.of(context)!.subscriptionManage, style: Theme.of(context).textTheme.bodyMedium,),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => const ManageSubscriptionScreen(),
              ),
              );
            },
          ),

          ListTile(
            dense: true,
            minLeadingWidth: 20,
            leading: const ExcludeSemantics(
              child: Icon(
                Icons.credit_card_off_outlined,
                size: 30,
                color: kDarkBlue,
              ),
            ),
            title: Text('Walkthrough', style: Theme.of(context).textTheme.bodyMedium,),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => WalkthroughScreen(prefs: widget.prefs),
              ),
              );
            },
          ),
          
          const ExcludeSemantics(child: Divider( color: kDarkBlue, thickness: 1.0, indent: 20, endIndent: 20)),
          ListTile(
            dense: true,
            minLeadingWidth: 20,
            leading: const ExcludeSemantics(
              child: Icon(
                Icons.help_outline,
                size: 30,
                color: kDarkBlue,
              ),
            ),
            title: Text(AppLocalizations.of(context)!.drawerSupport, style: Theme.of(context).textTheme.bodyMedium,),
            onTap: () {
              Navigator.of(context).pop();
              sendSupportEmail(context);
            },
          ),
          ListTile(
            dense: true,
            minLeadingWidth: 20,
            leading: const ExcludeSemantics(
              child: Icon(
                Icons.share,
                size: 30,
                color: kDarkBlue,
              ),
            ),
            title: Text(AppLocalizations.of(context)!.drawerInvite, style: Theme.of(context).textTheme.bodyMedium,),
            onTap: () {
              Navigator.of(context).pop();
              shareWolpz(context);
            },
          ),

          ListTile(
            dense: true,
            minLeadingWidth: 20,
            leading: const ExcludeSemantics(
              child: Icon(
                Icons.details,
                size: 30,
                color: kDarkBlue,
              ),
            ),
            title: Text(AppLocalizations.of(context)!.drawerTerms, style: Theme.of(context).textTheme.bodyMedium,),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => TermsAndPrivacyScreen(prefs: widget.prefs),), );

            },
          ),
          const ExcludeSemantics(child: Divider( color: kDarkBlue, thickness: 1.0, indent: 20, endIndent: 20)),
          Semantics(
            label: AppLocalizations.of(context)!.drawerLogout,
            child: ListTile(
              dense: true,
              minLeadingWidth: 20,
              leading: const ExcludeSemantics(
                child: Icon(
                  Icons.logout_outlined,
                  size: 30,
                  color: kDarkBlue,
                ),
              ),
              title: Text(AppLocalizations.of(context)!.drawerLogout, style: Theme.of(context).textTheme.bodyMedium,),
              onTap: () {
                Navigator.of(context).pop();
                auth.signOut();
              },
            ),
          ),
          Semantics(
            label: AppLocalizations.of(context)!.drawerRemove,
            child: ListTile(
              dense: true,
              minLeadingWidth: 20,
              leading: const ExcludeSemantics(
                child: Icon(
                  Icons.person_remove_alt_1_outlined,
                  size: 30,
                  color: kDarkBlue,
                ),
              ),
              title: Text(AppLocalizations.of(context)!.drawerRemove, style: Theme.of(context).textTheme.bodyMedium,),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const RemoveAccountScreen(),
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
