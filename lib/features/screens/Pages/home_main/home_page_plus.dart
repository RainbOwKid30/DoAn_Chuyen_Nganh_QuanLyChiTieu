import 'package:flutter/material.dart';

class HomePagePlus extends StatelessWidget {
  const HomePagePlus({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD0CBCB),
      body: Container(
        child: const Text(
          "page account",
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
