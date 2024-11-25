import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quan_ly_chi_tieu/features/models/list_icon.dart';

class HomePageIconpickerscreen extends StatelessWidget {
  const HomePageIconpickerscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Chọn Icon",
          style: TextStyle(
            color: Color(0xff000000),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          color: const Color(0xff000000),
          icon: const Icon(FontAwesomeIcons.angleLeft),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, // Số cột
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: iconPaths.length, // Số lượng icon
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Trả icon đã chọn về màn hình trước
              Navigator.pop(context, iconPaths[index]);
            },
            child: Image.asset(
              "assets/images/${iconPaths[index]}.png",
            ),
          );
        },
      ),
    );
  }
}
