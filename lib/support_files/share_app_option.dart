import 'dart:io';

import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:wolpz/l10n/app_localizations.dart';

Future<void> shareWolpz(BuildContext context) async {
  //TODO: Replace these with the actual store URLs once I have them
  const String appleStoreUrl = 'https://apps.apple.com/app/vocaleyes/id6755300954';
  const String googlePlayUrl = 'https://play.google.com/store/apps/details?id=com.baaadkitty.wolpz';

  String message = '';

  if (Platform.isAndroid) {
    String androidText = '${AppLocalizations.of(context)?.inviteMessage}$googlePlayUrl';
    message = androidText;
  } else if (Platform.isIOS) {
      String appleText = '${AppLocalizations.of(context)?.inviteMessage}$appleStoreUrl';
      message = appleText;
  }

  final box = context.findRenderObject() as RenderBox?;

  await SharePlus.instance.share(
      ShareParams(
        text: message.isEmpty ? null : message,
        subject: '${AppLocalizations.of(context)?.inviteTitle}',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      ),
  );
}