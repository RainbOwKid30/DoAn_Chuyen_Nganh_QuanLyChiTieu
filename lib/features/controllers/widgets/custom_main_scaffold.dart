import 'package:flutter/material.dart';

class CustomMainScaffold extends StatelessWidget {
  const CustomMainScaffold({super.key, this.child});
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD0CBCB),
      body: Stack(
        children: [
          SafeArea(
            child: child!,
          ),
        ],
      ),
    );
  }
}
