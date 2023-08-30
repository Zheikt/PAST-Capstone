import 'package:flutter/material.dart';

class HiddenToggleableTextFormField extends StatefulWidget {
  final TextEditingController passwordTextController;

  const HiddenToggleableTextFormField(
      {super.key, required this.passwordTextController});

  @override
  State<HiddenToggleableTextFormField> createState() =>
      _HiddenToggleableTextFormFieldState();
}

class _HiddenToggleableTextFormFieldState
    extends State<HiddenToggleableTextFormField> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.passwordTextController,
      obscureText: !showPassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
      decoration: InputDecoration(
        border: const UnderlineInputBorder(),
        labelText: 'Enter your password',
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary.withAlpha(180),
        ),
        suffixIcon: IconButton(
          icon: Icon(showPassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined),
          onPressed: () {
            setState(() {
              showPassword = !showPassword;
            });
          },
          color: Theme.of(context).colorScheme.inversePrimary.withAlpha(180),
        ),
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
    );
  }
}
