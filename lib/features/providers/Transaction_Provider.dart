import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TransactionProvider with ChangeNotifier {
  List<Map<String, dynamic>> expenseData = [];
  List<Map<String, dynamic>> incomeData = [];

  // Hàm tải dữ liệu từ Firestore
  Future<void> loadData(String userId) async {
    try {
      // Lắng nghe các thay đổi từ Firestore theo thời gian thực
      FirebaseFirestore.instance
          .collection('transactions')
          .doc('groups_thu_chi')
          .collection('KhoanThu')
          .where('userId', isEqualTo: userId)
          .snapshots() // Sử dụng snapshots() để nhận stream
          .listen((snapshot) {
        List<Map<String, dynamic>> incomes = [];
        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            incomes.add({
              'amount': data['amount'] ?? 0, // Gán 0 nếu 'amount' là null
              // Gán chuỗi rỗng nếu 'group' là null
              'group': data['group'] ?? '',
              // Gán ngày hiện tại nếu 'date' là null
              'date': (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
              // Gán chuỗi rỗng nếu 'note' là null
              'note': data['note'] ?? '',
            });
          }
        }
        // Cập nhật dữ liệu thu nhập
        incomeData = incomes;
        notifyListeners(); // Thông báo UI cập nhật
      });

      FirebaseFirestore.instance
          .collection('transactions')
          .doc('groups_thu_chi')
          .collection('KhoanChi')
          .where('userId', isEqualTo: userId)
          .snapshots() // Sử dụng snapshots() để nhận stream
          .listen((snapshot) {
        List<Map<String, dynamic>> expenses = [];
        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            expenses.add({
              'amount': data['amount'] ?? 0,
              'group': data['group'] ?? '',
              'date': (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
              'note': data['note'] ?? '',
            });
          }
        }
        // Cập nhật dữ liệu chi tiêu
        expenseData = expenses;
        notifyListeners(); // Thông báo UI cập nhật
      });
    } catch (e) {
      print('Lỗi khi tải dữ liệu: $e');
    }
  }

  // Tính tổng chi
  int get totalExpenses {
    return expenseData.fold<int>(0, (sum, item) {
      return sum + (item['amount'] as int); // Đảm bảo 'amount' là kiểu int
    });
  }

  // Tính tổng thu
  int get totalIncome {
    return incomeData.fold<int>(0, (sum, item) {
      return sum + (item['amount'] as int); // Đảm bảo 'amount' là kiểu int
    });
  }

  // Tính tổng thu - chi
  int get totalBalance {
    return totalIncome - totalExpenses; // Lãi hoặc lỗ
  }
}
