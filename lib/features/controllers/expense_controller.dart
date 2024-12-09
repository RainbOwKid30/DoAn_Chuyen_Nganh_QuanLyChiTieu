import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpenseController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hàm để lấy chi tiêu cho tuần và tháng
  Future<Map<String, double>> fetchExpenseData() async {
    // Khởi tạo các giá trị cần thiết
    double totalExpenseThisWeek = 0;
    double totalExpenseThisMonth = 0;

    // Lấy ngày hiện tại
    DateTime now = DateTime.now();

    // Tính toán ngày bắt đầu và kết thúc của tuần và tháng hiện tại
    DateTime startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfThisWeek = startOfThisWeek.add(const Duration(days: 6));
    DateTime startOfThisMonth = DateTime(now.year, now.month, 1);
    DateTime endOfThisMonth = DateTime(now.year, now.month + 1, 0);

    // Lấy userId từ FirebaseAuth
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("User not logged in.");
      return {}; // Trả về dữ liệu rỗng nếu không có userId
    }

    // Lấy dữ liệu chi tiêu từ Firestore
    QuerySnapshot expenseSnapshot = await _firestore
        .collection('transactions')
        .doc('groups_thu_chi')
        .collection('KhoanChi')
        .where('userId', isEqualTo: userId) // Lọc theo userId
        .get();

    // Xử lý dữ liệu chi tiêu
    for (var doc in expenseSnapshot.docs) {
      double amount = doc['amount'].toDouble();
      Timestamp date = doc['date'];
      DateTime dateTime = date.toDate();

      // Tính tổng chi tiêu cho tuần này
      if (dateTime.isAfter(startOfThisWeek.subtract(const Duration(days: 1))) &&
          dateTime.isBefore(endOfThisWeek.add(const Duration(days: 1)))) {
        totalExpenseThisWeek += amount.abs();
      }

      // Tính tổng chi tiêu cho tháng này
      if (dateTime
              .isAfter(startOfThisMonth.subtract(const Duration(days: 1))) &&
          dateTime.isBefore(endOfThisMonth.add(const Duration(days: 1)))) {
        totalExpenseThisMonth += amount.abs();
      }
    }

    // Trả về một Map với kết quả
    return {
      'thisWeek': totalExpenseThisWeek,
      'thisMonth': totalExpenseThisMonth,
    };
  }
}
