import 'package:cloud_firestore/cloud_firestore.dart';
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

      QuerySnapshot budgetSnapshot = await FirebaseFirestore.instance
          .collection('budgets')
          .where('startDate', isGreaterThanOrEqualTo: firstDayOfMonth)
          .where('startDate', isLessThanOrEqualTo: lastDayOfMonth)
          .get();

      double totalBudget = 0;
      List<Map<String, dynamic>> items = [];

      List<String> categoryIds = [];

      for (var doc in budgetSnapshot.docs) {
        totalBudget += doc['amount'];
        String categoryId = doc['categoryId'];
        categoryIds.add(categoryId);

        await _fetchCategoryInfo(categoryId).then((categoryInfo) {
          items.add({
            'id': doc.id,
            'category': categoryInfo['name'],
            'icon': categoryInfo['icon'],
            'amount': doc['amount'],
            'remainingAmount': doc['amount'],
            'categoryId': categoryId,
          });
        });
      }

      double totalSpent = 0;

      if (categoryIds.isNotEmpty && totalBudget > 0) {
        QuerySnapshot transactionSnapshot = await FirebaseFirestore.instance
            .collection('transactions')
            .doc('groups_thu_chi')
            .collection('KhoanChi')
            .where('date', isGreaterThanOrEqualTo: firstDayOfMonth)
            .where('date', isLessThanOrEqualTo: lastDayOfMonth)
            .where('categoryId', whereIn: categoryIds)
            .get();

        for (var doc in transactionSnapshot.docs) {
          totalSpent += doc['amount'];
        }

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

  Future<Map<String, dynamic>> _fetchCategoryInfo(String categoryId) async {
    try {
      DocumentSnapshot categoryDoc = await FirebaseFirestore.instance
          .collection('categories')
          .doc('group_category')
          .collection('KhoanChi')
          .doc(categoryId)
          .get();

      if (categoryDoc.exists) {
        return {
          'name': categoryDoc['name'],
          'icon': categoryDoc['icon'],
        };
      } else {
        return {
          'name': 'Không có tên',
          'icon': Icons.help_outline,
        };
      }
    } catch (e) {
      print("Error fetching category info: $e");
      return {
        'name': 'Không có tên',
        'icon': Icons.help_outline,
      };
    }
  }
}
