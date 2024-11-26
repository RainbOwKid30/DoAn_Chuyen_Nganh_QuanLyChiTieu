import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TransactionProvider with ChangeNotifier {
  List<Map<String, dynamic>> expenseData = [];
  List<Map<String, dynamic>> incomeData = [];

  // Hàm tải dữ liệu theo tháng
  Future<void> loadDataByMonth(String userId, int month, int year) async {
    try {
      // Xác định ngày bắt đầu và kết thúc của tháng
      DateTime startOfMonth = DateTime(year, month, 1);
      DateTime endOfMonth = DateTime(year, month + 1, 1);

      // Lọc dữ liệu thu nhập theo tháng
      FirebaseFirestore.instance
          .collection('transactions')
          .doc('groups_thu_chi')
          .collection('KhoanThu')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThan: endOfMonth)
          .snapshots()
          .listen((snapshot) {
        incomeData = snapshot.docs.map((doc) {
          var data = doc.data();
          return {
            'amount': data['amount'] ?? 0,
            'group': data['group'] ?? '',
            'date': (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
            'note': data['note'] ?? '',
          };
        }).toList();
        notifyListeners();
      });

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
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Lỗi khi tải dữ liệu: $e');
    }
  }

  // Hàm tải dữ liệu theo ngày
  Future<void> loadDataByDay(String userId, DateTime date) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('date',
              isGreaterThanOrEqualTo: DateTime(date.year, date.month, date.day))
          .where('date',
              isLessThan: DateTime(date.year, date.month, date.day + 1))
          .get();

      incomeData = [];
      expenseData = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        if (data['type'] == 'income') {
          incomeData.add(data);
        } else if (data['type'] == 'expense') {
          expenseData.add(data);
        }
      }
      notifyListeners();
    } catch (e) {
      print("Error loading data for day: $e");
    }
  }

  // Hàm tải dữ liệu theo năm
  Future<void> loadDataByYear(String userId, int year) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: DateTime(year, 1, 1))
          .where('date', isLessThan: DateTime(year + 1, 1, 1))
          .get();

      incomeData = [];
      expenseData = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        if (data['type'] == 'income') {
          incomeData.add(data);
        } else if (data['type'] == 'expense') {
          expenseData.add(data);
        }
      }
      notifyListeners();
    } catch (e) {
      print("Error loading data for year: $e");
    }
  }

  // Hàm tải dữ liệu từ Firestore
  Future<void> loadData(String userId) async {
    try {
      // Tải dữ liệu thu nhập
      FirebaseFirestore.instance
          .collection('transactions')
          .doc('groups_thu_chi')
          .collection('KhoanThu')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .listen((snapshot) {
        incomeData = snapshot.docs.map((doc) {
          var data = doc.data();
          return {
            'amount': data['amount'] ?? 0,
            'group': data['group'] ?? '',
            'date': (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
            'note': data['note'] ?? '',
          };
        }).toList();
        notifyListeners();
      });

      // Tải dữ liệu chi tiêu
      FirebaseFirestore.instance
          .collection('transactions')
          .doc('groups_thu_chi')
          .collection('KhoanChi')
          .where('userId', isEqualTo: userId)
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
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Lỗi khi tải dữ liệu: $e');
    }
  }

  // Tính tổng chi
  int get totalExpenses =>
      expenseData.fold(0, (sum, item) => sum + (item['amount'] as int));

  // Tính tổng thu
  int get totalIncome =>
      incomeData.fold(0, (sum, item) => sum + (item['amount'] as int));

  // Tính tổng số dư
  int get totalBalance => totalIncome - totalExpenses;
}
