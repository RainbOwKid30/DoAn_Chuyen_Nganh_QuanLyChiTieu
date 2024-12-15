import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_page_custom/home_page_IconPickerScreen.dart';

class HomePageNewItem extends StatefulWidget {
  final String categoryType; // Biến xác định là Khoản Chi hay Khoản Thu

  const HomePageNewItem({super.key, required this.categoryType});

  @override
  State<HomePageNewItem> createState() => _HomePageNewItemState();
}

class _HomePageNewItemState extends State<HomePageNewItem> {
  IconData? selectedIcon0; // Biến lưu icon được chọn
  String? selectedIconPath;
  // Controller cho TextField
  final TextEditingController _nameController = TextEditingController();
  //id user
  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "New Group",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          color: const Color(0xff000000),
          icon: const Icon(FontAwesomeIcons.angleLeft),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dòng đầu tiên: Nhập tên nhóm và chọn icon
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePageIconpickerscreen(),
                      ),
                    );
                    if (result != null && result is String) {
                      setState(() {
                        selectedIconPath = result;
                      });
                    }
                  },
                  child: selectedIconPath != null
                      ? Image.asset("assets/images/${selectedIconPath!}.png",
                          width: 50, height: 50)
                      : const Icon(Icons.add_circle, size: 50),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextField(
                    controller:
                        _nameController, // Sử dụng controller để quản lý TextField
                    decoration: const InputDecoration(
                      labelText: "Group name",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Dòng thứ hai: Hiển thị categoryType và icon mặc định
            Row(
              children: [
                Image.asset(
                  "assets/images/borrow.png", // Hình ảnh mặc định
                  width: 50,
                  height: 50,
                ),
                const SizedBox(width: 20),
                Text(
                  widget.categoryType,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Nút lưu nhóm
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  String categoryTypeSubCollection =
                      widget.categoryType == 'Khoản Chi'
                          ? 'KhoanChi'
                          : 'KhoanThu';
                  if (_nameController.text.isNotEmpty &&
                      selectedIconPath != null) {
                    if (userId != null) {
                      await FirebaseFirestore.instance
                          .collection('categories')
                          .doc("group_category")
                          .collection(categoryTypeSubCollection)
                          .add({
                        'userId': userId,
                        'name': _nameController.text,
                        'icon': selectedIconPath,
                        'category': widget.categoryType,
                      });
                      Navigator.pop(context, true);
                    }
                  }
                },
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
