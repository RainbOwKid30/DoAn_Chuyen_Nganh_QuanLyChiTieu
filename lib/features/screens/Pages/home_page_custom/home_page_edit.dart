import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quan_ly_chi_tieu/features/models/user_model.dart';

class HomePageEdit extends StatefulWidget {
  const HomePageEdit({super.key});

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<HomePageEdit> {
  final User? firebaseUser = FirebaseAuth.instance.currentUser;
  UserModel? userModel;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool isEditingName = false;
  bool isEditingEmail = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Tải dữ liệu người dùng từ Firestore
  Future<void> _loadUserData() async {
    if (firebaseUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(firebaseUser!.uid)
          .get();
      if (doc.exists) {
        userModel = UserModel.fromJson(doc.data()!, doc.id);
        _nameController.text = userModel!.fullName;
        _emailController.text = userModel!.email;
      }
    }
  }

  // Lưu thay đổi người dùng vào Firestore
  Future<void> _saveChanges() async {
    if (firebaseUser != null) {
      // Cập nhật thông tin người dùng
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(firebaseUser!.uid)
          .update({
        'FullName': _nameController.text,
        'Email': _emailController.text,
      });

      setState(() {
        isEditingName = false;
        isEditingEmail = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thông tin người dùng đã được cập nhật")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Thông tin người dùng",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          color: const Color(0xff000000),
          icon: const Icon(FontAwesomeIcons.angleLeft),
          onPressed: () {
            Navigator.pop(context); // Quay lại trang trước
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Tên người dùng
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration:
                        const InputDecoration(labelText: "Tên người dùng"),
                    enabled: isEditingName,
                  ),
                ),
                IconButton(
                  icon: Icon(isEditingName ? Icons.check : Icons.edit),
                  onPressed: () {
                    setState(() {
                      isEditingName = !isEditingName;
                    });
                  },
                ),
              ],
            ),
            // Email
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    enabled: isEditingEmail,
                  ),
                ),
                IconButton(
                  icon: Icon(isEditingEmail ? Icons.check : Icons.edit),
                  onPressed: () {
                    setState(() {
                      isEditingEmail = !isEditingEmail;
                    });
                  },
                ),
              ],
            ),
            // Đẩy nút "Lưu" xuống cuối màn hình
            const Spacer(),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                // Độ rộng đầy đủ
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Lưu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
