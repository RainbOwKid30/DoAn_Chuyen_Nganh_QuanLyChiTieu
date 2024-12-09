import 'package:flutter/material.dart';

class TogglePassword extends StatelessWidget {
  final bool isSecurePassword;
  final VoidCallback onPressed;

  const TogglePassword({
    super.key,
    required this.isSecurePassword,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: isSecurePassword
          ? const Icon(Icons.visibility_off)
          : const Icon(Icons.visibility),
      color: Colors.grey,
    );
  }
}
