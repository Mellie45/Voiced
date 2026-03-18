import 'package:flutter/material.dart';
import 'package:wolpz/support_files/constants.dart';

class CustomPasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType inputType;
  final bool? obscureText;
  final bool isPassword;
  final Function validator;
  final void Function(dynamic _) onChanged;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final Color? iconColor;

  const CustomPasswordField({super.key,
    required this.label,
    required this.controller,
    required this.inputType,
    this.obscureText,
    required this.isPassword,
    required this.validator,
    required this.onChanged,
    this.autofillHints,
    this.textInputAction,
    this.iconColor = kDarkBlue,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: SizedBox(
        child: TextFormField(
          style: Theme.of(context).textTheme.bodyMedium,
          obscureText: widget.isPassword ? !_showPassword : false,
          keyboardType: widget.inputType,
          autofillHints: widget.autofillHints,
          textInputAction: widget.textInputAction,
          validator: (value) => widget.validator(value),
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
            suffixIcon: widget.isPassword
                ? IconButton(
              icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility,
                color: widget.iconColor,
                size: 32,),
              onPressed: () => setState(() => _showPassword = !_showPassword),
              tooltip: _showPassword ? 'Hide password' : 'Show password',
            )
                : null,
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
                width: 1.0,
              ),
            ),// Don't show any icon for non-password fields
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(14.0)),
          ),
        ),
      ),
    );
  }
}
