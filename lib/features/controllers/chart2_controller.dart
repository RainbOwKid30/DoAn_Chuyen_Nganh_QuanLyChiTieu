import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Chart2Controller {
  Future<Map<String, dynamic>> fetchExpenseData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    double totalExpenseThisMonth = 0;
    double totalExpenseLastMonth = 0;

    DateTime now = DateTime.now();
    DateTime startOfThisMonth =
        DateTime(now.year, now.month, 1); // Ngày bắt đầu của tháng này
    DateTime endOfThisMonth =
        DateTime(now.year, now.month + 1, 0); // Ngày kết thúc của tháng này
    DateTime startOfLastMonth =
        DateTime(now.year, now.month - 1, 1); // Ngày bắt đầu của tháng trước
    DateTime endOfLastMonth =
        DateTime(now.year, now.month, 0); // Ngày kết thúc của tháng trước

    // Định dạng ngày tháng cho tháng trước
    String formattedStartLastMonth =
        '${startOfLastMonth.day} thg ${startOfLastMonth.month}';
    String formattedEndLastMonth =
        '${endOfLastMonth.day} thg ${endOfLastMonth.month}';

    // Lấy userId từ FirebaseAuth
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("User not logged in.");
      return {}; // Trả về dữ liệu rỗng nếu không có userId
    }

    // Lấy dữ liệu từ Firestore theo userId trong collection 'KhoanChi'
    QuerySnapshot expenseSnapshot = await firestore
        .collection('transactions')
        .doc('groups_thu_chi')
        .collection('KhoanChi')
        .where('userId', isEqualTo: userId) // Lọc theo userId
        .get();

    for (var doc in expenseSnapshot.docs) {
      double amount = doc['amount'].toDouble();
      Timestamp date = doc['date'];
      DateTime dateTime = date.toDate();

      // Tổng chi tiêu cho tháng này
      if (dateTime
              .isAfter(startOfThisMonth.subtract(const Duration(days: 1))) &&
          dateTime.isBefore(endOfThisMonth.add(const Duration(days: 1)))) {
        totalExpenseThisMonth += amount.abs();
      }
      // Tổng chi tiêu cho tháng trước
      if (dateTime
              .isAfter(startOfLastMonth.subtract(const Duration(days: 1))) &&
          dateTime.isBefore(endOfLastMonth.add(const Duration(days: 1)))) {
        totalExpenseLastMonth += amount.abs();
      }
    }

    // Trả về dữ liệu cho tháng này và tháng trước
    return {
      'thisMonth': totalExpenseThisMonth,
      'lastMonth': totalExpenseLastMonth,
      'formattedStartLastMonth': formattedStartLastMonth,
      'formattedEndLastMonth': formattedEndLastMonth,
    };
  }
}
