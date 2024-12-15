import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BudgetProvider with ChangeNotifier {
  double totalBudget = 0;
  double spent = 0;
  double sotienconlai = 0;
  List<Map<String, dynamic>> budgetItems = [];
  Future<void> fetchBudgetData() async {
    try {
      DateTime now = DateTime.now();
      int currentYear = now.year;
      int currentMonth = now.month;

      DateTime firstDayOfMonth = DateTime(currentYear, currentMonth, 1);
      DateTime lastDayOfMonth = DateTime(currentYear, currentMonth + 1, 0);

      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Lấy dữ liệu ngân sách
      QuerySnapshot budgetSnapshot = await FirebaseFirestore.instance
          .collection('budgets')
          .where('userId', isEqualTo: userId)
          .where('startDate', isGreaterThanOrEqualTo: firstDayOfMonth)
          .where('endDate', isLessThanOrEqualTo: lastDayOfMonth)
          .get();

      double totalBudget = 0;
      List<Map<String, dynamic>> items = [];
      List<String> categoryIds = [];

      // Tải danh sách tất cả categories trước
      Map<String, Map<String, dynamic>> categoryCache = {};
      for (var doc in budgetSnapshot.docs) {
        totalBudget += doc['amount'];
        String categoryId = doc['categoryId'];
        categoryIds.add(categoryId);
      }

      // Lấy thông tin category một lần và cache lại
      if (categoryIds.isNotEmpty) {
        QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
            .collection('categories')
            .doc('group_category')
            .collection('KhoanChi')
            .where(FieldPath.documentId, whereIn: categoryIds)
            .get();

        // Tạo cache cho categories
        for (var categoryDoc in categorySnapshot.docs) {
          categoryCache[categoryDoc.id] = {
            'name': categoryDoc['name'],
            'icon': categoryDoc['icon'],
          };
        }

        // Sử dụng thông tin category đã cache cho các mục ngân sách
        for (var doc in budgetSnapshot.docs) {
          String categoryId = doc['categoryId'];
          var categoryInfo = categoryCache[categoryId] ??
              {
                'name': 'Không có tên',
                'icon': Icons.help_outline,
              };

          items.add({
            'id': doc.id,
            'category': categoryInfo['name'],
            'icon': categoryInfo['icon'],
            'amount': doc['amount'],
            'startDate': doc['startDate'],
            'endDate': doc['endDate'],
            'remainingAmount': doc['amount'],
            'categoryId': categoryId,
          });
        }
      }

      double totalSpent = 0;

      if (categoryIds.isNotEmpty && totalBudget > 0) {
        QuerySnapshot transactionSnapshot = await FirebaseFirestore.instance
            .collection('transactions')
            .doc('groups_thu_chi')
            .collection('KhoanChi')
            .where('userId', isEqualTo: userId)
            .where('date', isGreaterThanOrEqualTo: firstDayOfMonth)
            .where('date', isLessThanOrEqualTo: lastDayOfMonth)
            .where('categoryId', whereIn: categoryIds)
            .get();

        for (var doc in transactionSnapshot.docs) {
          totalSpent += doc['amount'];
        }

        // Cập nhật remainingAmount cho từng mục ngân sách
        for (var i = 0; i < items.length; i++) {
          String categoryId = items[i]['categoryId'];
          double spentForCategory = 0;

          for (var doc in transactionSnapshot.docs) {
            if (doc['categoryId'] == categoryId) {
              spentForCategory += doc['amount'];
            }
          }

          items[i]['remainingAmount'] = items[i]['amount'] - spentForCategory;
        }
      }

      this.totalBudget = totalBudget;
      spent = totalSpent;
      sotienconlai = totalBudget - totalSpent;
      budgetItems = items;
      notifyListeners();
    } catch (e) {
      print("Error fetching budget data: $e");
    }
  }

  Future<void> updateBudgetItem(Map<String, dynamic> updatedItem) async {
    try {
      // Cập nhật lại ngân sách trong Firestore
      await FirebaseFirestore.instance
          .collection('budgets')
          .doc(updatedItem['id'])
          .update({
        'amount': updatedItem['amount'],
        // Cập nhật thêm các thông tin khác nếu cần
      });

      // Sau khi cập nhật dữ liệu, fetch lại ngân sách
      await fetchBudgetData(); // Lấy lại dữ liệu ngân sách mới
    } catch (e) {
      print("Lỗi khi cập nhật ngân sách: $e");
    }
  }

  Future<void> addOrUpdateBudget(Map<String, dynamic> newBudget) async {
    try {
      DateTime now = DateTime.now();
      int currentYear = now.year;
      int currentMonth = now.month;

      // Lấy userId từ Firebase Authentication
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Kiểm tra xem đã có ngân sách với category và tháng năm này chưa
      QuerySnapshot budgetSnapshot = await FirebaseFirestore.instance
          .collection('budgets')
          .where('userId', isEqualTo: userId)
          .where('categoryId',
              isEqualTo: newBudget['categoryId']) // Kiểm tra category
          .where('startDate',
              isGreaterThanOrEqualTo: DateTime(currentYear, currentMonth, 1))
          .where('startDate',
              isLessThanOrEqualTo:
                  DateTime(currentYear, currentMonth + 1, 0)) // Tháng hiện tại
          .get();

      if (budgetSnapshot.docs.isNotEmpty) {
        // Nếu đã có ngân sách cho category trong tháng hiện tại, chỉ cần cập nhật số tiền
        DocumentSnapshot existingBudget = budgetSnapshot.docs.first;
        double existingAmount = existingBudget['amount'];
        double updatedAmount =
            existingAmount + newBudget['amount']; // Cộng thêm số tiền mới

        await FirebaseFirestore.instance
            .collection('budgets')
            .doc(existingBudget.id)
            .update({'amount': updatedAmount}); // Cập nhật lại số tiền

        print("Đã cập nhật ngân sách thành công.");
      } else {
        // Nếu chưa có, tạo một mục ngân sách mới
        await FirebaseFirestore.instance.collection('budgets').add({
          'userId': userId,
          'categoryId': newBudget['categoryId'],
          'startDate': newBudget['startDate'],
          'amount': newBudget['amount'],
          // Các trường khác nếu cần
        });

        print("Đã thêm ngân sách mới.");
      }
    } catch (e) {
      print("Lỗi khi thêm hoặc cập nhật ngân sách: $e");
    }
  }
}
