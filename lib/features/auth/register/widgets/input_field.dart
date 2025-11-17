import 'package:flutter/material.dart';

class RegisterInputField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hint;
  final bool isPassword;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  const RegisterInputField({
    super.key,
    this.controller,
    this.hint,
    this.isPassword = false,
    this.validator,
    this.prefixIcon,
  });

  @override
  State<RegisterInputField> createState() => _RegisterInputFieldState();
}

class _RegisterInputFieldState extends State<RegisterInputField> {
  bool obscureText = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: widget.isPassword ? obscureText : !obscureText,
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: widget.hint,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    obscureText = !obscureText;
                  });
                },
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                ),
              )
            : null,
      ),
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUnfocus,
    );
  }
}
