import 'package:flutter/material.dart';

class CustomFlatButton extends StatelessWidget {
  final String title;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final VoidCallback onPressed;
  final Color color;
  final Color splashColor;
  final Color borderColor;
  final double borderWidth;

  const CustomFlatButton(
      {super.key,
        required this.title,
        required this.textColor,
        required this.fontSize,
        required this.fontWeight,
        required this.onPressed,
        required this.color,
        required this.splashColor,
        required this.borderColor,
        required this.borderWidth});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          elevation: 0.0,
          backgroundColor: color,
          side: BorderSide(width: borderWidth, color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.0),
          )),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          title,
          softWrap: true,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)
        ),
      ),
    );
  }
}
