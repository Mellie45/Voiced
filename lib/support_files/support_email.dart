import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

Future<void> sendSupportEmail(BuildContext context) async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceDetail = '';
  const String email = 'wolpz.support@baaadkitty.uk';
  const String subject = 'Wolpz Support Request';


  try {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceDetail = 'Android ${androidInfo.version.release} - ${androidInfo.model}';

    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceDetail = 'iOS ${iosInfo.systemVersion} - ${iosInfo.utsname.machine}';
    }
  } catch (e) {
    deviceDetail = 'Unknown Device';
    debugPrint('Error getting device info: $e');
  }

  final String userPrompt = AppLocalizations.of(context)?.supportEmailBody?? 'Please describe your issue here...';

  final String body = '$userPrompt\n\n'
      '--------------------------\n'
      'TECHNICAL DATA (Internal Use Only):\n'
      'App Version: 1.0.0\n'
      'Device: $deviceDetail';

  final Uri emailLaunchUri = Uri.parse(
    'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
  );

  if (await canLaunchUrl(emailLaunchUri)) {
    await launchUrl(
        emailLaunchUri,
        mode: LaunchMode.externalApplication,
    );
  } else {
    debugPrint('Could not launch email app');

  }
}