import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quan_ly_chi_tieu/features/models/user_model.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/App_main/my_app.dart';

class SignupController {
  // Hàm đăng ký
  static Future<void> registration({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
    required Function(bool isLoading) setLoading,
  }) async {
    setLoading(true); // Hiển thị trạng thái loading
    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      try {
        // Tạo tài khoản Firebase
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        // Cập nhật tên người dùng
        await userCredential.user?.updateProfile(displayName: name);

        // Tạo đối tượng UserModel
        UserModel user = UserModel(
          id: userCredential.user?.uid,
          fullName: name,
          email: email,
          password: password,
        );

        // Lưu dữ liệu người dùng vào Firestore
        await saveUserData(user);

        // Hiển thị thông báo đăng ký thành công
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Registered Successfully",
              style: TextStyle(fontSize: 20.0),
            )));

        // Điều hướng đến trang chính
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MyWidget()),
          (route) => false,
        );
      } on FirebaseAuthException catch (e) {
        String errorMsg = e.code == 'weak-password'
            ? "Password Provided is too weak"
            : e.code == "email-already-in-use"
                ? "Account Already exists"
                : "An error occurred";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              errorMsg,
              style: const TextStyle(fontSize: 20.0),
            )));
      } finally {
        setLoading(false); // Ẩn trạng thái loading
      }
    } else {
      setLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Please fill in all fields",
            style: TextStyle(fontSize: 20.0),
          )));
    }
  }

  // Hàm lưu dữ liệu người dùng vào Firestore
  static Future<void> saveUserData(UserModel user) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .set(user.toJson());
      print("User data saved successfully");
    } catch (e) {
      print("Error saving user data: $e");
    }
  }
}
