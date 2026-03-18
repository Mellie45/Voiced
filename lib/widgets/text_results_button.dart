import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../support_files/constants.dart';

class TextResultsButton extends StatelessWidget {
  final String text;

  const TextResultsButton({
    super.key,
    required this.text,
  });

  void _showModal(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context)!;
    final ScrollController modalScrollController = ScrollController();

    showModalBottomSheet(
      backgroundColor: kDarkBlue,
      useSafeArea: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.0)),
      ),
      barrierColor: kDarkOrange,
      context: context,
      builder: (context) => SizedBox(
        height: height * 0.8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thumbColor: WidgetStateProperty.all<Color>(kDarkOrange),
                    trackColor: WidgetStateProperty.all<Color>(Colors.white),
                    trackBorderColor: WidgetStateProperty.all<Color>(kDarkOrange),
                    radius: const Radius.circular(12.0),
                    thickness: WidgetStateProperty.all(12.0),
                  ),
                  child: Scrollbar(
                    controller: modalScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    interactive: true,
                    child: SingleChildScrollView(
                      controller: modalScrollController,
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Text(
                        text,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 60,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: kDarkOrange, width: 2.0),
                      ),
                    ),
                    Semantics(
                      label: localizations.selectImageScreenCloseButton,
                      button: true,
                      onTap: () => Navigator.pop(context),
                      child: TextButton.icon(
                        icon: const ExcludeSemantics(
                          child: Icon(
                            Icons.close_rounded,
                            color: kDarkOrange,
                            size: 34.0,
                            weight: 900,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        label: ExcludeSemantics(
                          child: Text(
                            localizations.selectImageScreenCloseButton,
                            style: const TextStyle(
                              color: kDarkOrange,
                              fontSize: 24,
                              letterSpacing: 1.6,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final localizations = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => _showModal(context),
      child: Container(
        alignment: Alignment.center,
        width: width,
        decoration: BoxDecoration(
          color: kDarkBlue,
          borderRadius: BorderRadius.circular(22.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22.0),
          child: Text(
            localizations.selectImageScreenShowTextBtn,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: kBackgroundTint),
          ),
        ),
      ),
    );
  }
}