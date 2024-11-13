import 'package:flutter/material.dart';

class HomePageBudget extends StatelessWidget {
  const HomePageBudget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD0CBCB),
      appBar: AppBar(
        title: const Text(
          "Ngân sách",
          style: TextStyle(color: Color(0xFF000000)),
        ),
        leading: IconButton(
          color: const Color(0xff000000),
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Quay lại trang trước
          },
        ),
      ),
      body: const Center(
        child: Text("Nội dung của trang ngan sach"),
      ),
    );
  }
}
