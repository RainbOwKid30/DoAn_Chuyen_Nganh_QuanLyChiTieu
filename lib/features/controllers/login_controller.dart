import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/App_main/my_app.dart';

class LoginController {
  static Future<void> userLogin({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Chuyển hướng sau khi đăng nhập thành công
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyWidget()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = "User not found";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password";
      } else {
        errorMessage = "An error occurred";
      }

      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            errorMessage,
            style: const TextStyle(fontSize: 20.0),
          ),
        ),
      );
    }
  }
}
