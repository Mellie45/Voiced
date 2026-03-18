import 'package:flutter/material.dart';

class MainFlatButton extends StatelessWidget {
  final String title;
  final VoidCallback pressed;
  final Color background;
  final TextStyle textStyle;
  final Color? borderColor;


  const MainFlatButton({super.key,
    required this.title,
    required this.pressed,
    required this.background,
    required this.textStyle,
    this.borderColor});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        side: BorderSide(color: borderColor ?? Colors.transparent),
        backgroundColor: background,
      ),
      onPressed: pressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        child: ExcludeSemantics(
          child: Text(
            title,
            softWrap: true,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        ),
      ),
    );
  }
}
