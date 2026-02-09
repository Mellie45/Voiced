import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

class LanguageFlagButton extends StatefulWidget {
  final String countryCode;
  final VoidCallback onTap;

  const LanguageFlagButton({
    super.key,
    required this.countryCode,
    required this.onTap,
  });

  @override
  State<LanguageFlagButton> createState() => _LanguageFlagButtonState();
}

class _LanguageFlagButtonState extends State<LanguageFlagButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) => setState(() => _scale = 0.85);
  void _onTapUp(TapUpDetails details) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: CountryFlag.fromCountryCode(
            widget.countryCode,
            theme: const ImageTheme(width: 56, height: 56, shape: Circle()),
          ),
        ),
      ),
    );
  }
}