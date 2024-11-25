import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomBuildUserName extends StatelessWidget {
  const CustomBuildUserName({super.key, this.user});
  final User? user;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(user?.uid) // Lấy thông tin người dùng từ Firestore
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Text("Lỗi khi tải dữ liệu người dùng");
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text(
            user?.displayName ?? "Tên người dùng chưa cập nhật",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          );
        }

        // Lấy dữ liệu FullName từ Firestore (nếu có)
        var userData = snapshot.data!.data() as Map<String, dynamic>;
        return Text(
          userData['FullName'] ??
              user?.displayName ??
              "Tên người dùng chưa cập nhật",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}
