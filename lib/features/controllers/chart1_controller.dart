import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Chart1Controller {
  Future<Map<String, dynamic>> fetchExpenseData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    double totalExpenseThisWeek = 0;
    double totalExpenseLastWeek = 0;

    DateTime now = DateTime.now();
    DateTime startOfThisWeek =
        now.subtract(Duration(days: now.weekday - 1)); // Monday
    DateTime endOfThisWeek =
        startOfThisWeek.add(const Duration(days: 6)); // Sunday
    DateTime startOfLastWeek =
        startOfThisWeek.subtract(const Duration(days: 7)); // Last Monday
    DateTime endOfLastWeek =
        startOfThisWeek.subtract(const Duration(days: 1)); // Last Sunday

    // Định dạng ngày tháng cho tuần trước
    String formattedStartLastWeek =
        '${startOfLastWeek.day} thg ${startOfLastWeek.month}';
    String formattedEndLastWeek =
        '${endOfLastWeek.day} thg ${endOfLastWeek.month}';

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

      // Tổng tiền chi cho tuần này
      if (dateTime.isAfter(startOfThisWeek.subtract(const Duration(days: 1))) &&
          dateTime.isBefore(endOfThisWeek.add(const Duration(days: 1)))) {
        totalExpenseThisWeek += amount.abs();
      }
      // Tổng tiền chi cho tuần trước
      else if (dateTime
              .isAfter(startOfLastWeek.subtract(const Duration(days: 1))) &&
          dateTime.isBefore(endOfLastWeek.add(const Duration(days: 1)))) {
        totalExpenseLastWeek += amount.abs();
      }
    }

    // Trả về dữ liệu dưới dạng Map bao gồm cả thông tin ngày tháng tuần trước
    return {
      'thisWeek': totalExpenseThisWeek,
      'lastWeek': totalExpenseLastWeek,
      'formattedStartLastWeek': formattedStartLastWeek,
      'formattedEndLastWeek': formattedEndLastWeek,
    };
  }
}
