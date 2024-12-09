import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CategoryProvider with ChangeNotifier {
  List<Map<String, dynamic>> expenseData = [];
  List<Map<String, dynamic>> incomeData = [];

  // Hàm tải dữ liệu từ Firestore
  Future<void> loadData(String userId) async {
    try {
      // Lắng nghe các thay đổi từ Firestore theo thời gian thực
      FirebaseFirestore.instance
          .collection('categories')
          .doc("group_category")
          .collection('KhoanThu')
          .where('userId', isEqualTo: userId)
          .snapshots() // Sử dụng snapshots() để nhận stream
          .listen((snapshot) {
        List<Map<String, dynamic>> incomes = [];
        for (var doc in snapshot.docs) {
          var data = doc.data();
          incomes.add({
            'userId': data["userId"],
            'name': data["name"],
            'icon': data["icon"],
            'category': data["category"],
          });
        }
        // Cập nhật dữ liệu thu nhập
        incomeData = incomes;
        notifyListeners(); // Thông báo UI cập nhật
      });

      FirebaseFirestore.instance
          .collection('categories')
          .doc("group_category")
          .collection('KhoanChi')
          .where('userId', isEqualTo: userId)
          .snapshots() // Sử dụng snapshots() để nhận stream
          .listen((snapshot) {
        List<Map<String, dynamic>> expenses = [];
        for (var doc in snapshot.docs) {
          var data = doc.data();
          expenses.add({
            'userId': data["userId"],
            'name': data["name"],
            'icon': data["icon"],
            'category': data["category"],
          });
        }
        // Cập nhật dữ liệu chi tiêu
        expenseData = expenses;
        notifyListeners(); // Thông báo UI cập nhật
      });
    } catch (e) {
      print('Lỗi khi tải dữ liệu: $e');
    }
  }
}
