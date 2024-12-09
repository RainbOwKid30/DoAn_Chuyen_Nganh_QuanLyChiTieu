import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DataLoader extends ChangeNotifier {
  List<Map<String, dynamic>> expenseData = [];
  double totalSpending = 0;

  // Hàm tải dữ liệu chi tiêu theo tháng và tính tổng chi
  Future<void> loadDataByMonth(String userId, int month, int year) async {
    try {
      // Xác định ngày bắt đầu và kết thúc của tháng
      DateTime startOfMonth = DateTime(year, month, 1);
      DateTime endOfMonth = DateTime(year, month + 1, 1);

      // Lọc dữ liệu chi tiêu theo tháng
      FirebaseFirestore.instance
          .collection('transactions')
          .doc('groups_thu_chi')
          .collection('KhoanChi')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThan: endOfMonth)
          .snapshots()
          .listen((snapshot) {
        expenseData = snapshot.docs.map((doc) {
          var data = doc.data();
          return {
            'amount': data['amount'] ?? 0,
            'group': data['group'] ?? '',
            'date': (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
            'note': data['note'] ?? '',
          };
        }).toList();

        // Tính tổng chi sau khi dữ liệu chi được tải về
        totalSpending =
            expenseData.fold(0, (sum, item) => sum + (item['amount'] ?? 0));
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Lỗi khi tải dữ liệu: $e');
    }
  }

  // Hàm trả về tổng chi
  double getTotalSpending() {
    return totalSpending;
  }
}
