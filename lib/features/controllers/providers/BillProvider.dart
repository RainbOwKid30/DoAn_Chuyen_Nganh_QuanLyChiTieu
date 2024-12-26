import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Billprovider with ChangeNotifier {
  double totalTransaction = 0;
  double spent = 0;
  double sotienconlai = 0;
  List<Map<String, dynamic>> budgetItems = [];
  List<Map<String, dynamic>> billData = [];

  // Fetch Bill Data
  Future<void> fetchBillData() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Lấy danh sách hóa đơn theo userId
      QuerySnapshot billSnapshot = await FirebaseFirestore.instance
          .collection('bills')
          .where('userId', isEqualTo: userId)
          .get();

      double totalAmount = 0;
      List<Map<String, dynamic>> billItems = [];
      Set<String> categoryIds = {};

      // Duyệt qua các hóa đơn
      for (var doc in billSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        totalAmount += data['amount'];
        categoryIds.add(data['categoryId']);

        billItems.add({
          'id': doc.id,
          'name': data['name'],
          'amount': data['amount'],
          'dueDate': data['dueDate'],
          'frequency': data['frequency'],
          'status': data['status'],
          'note': data['note'],
          'categoryId': data['categoryId'],
        });
      }

      // Lấy thông tin danh mục (categories) liên quan
      Map<String, Map<String, dynamic>> categoryCache =
          await _fetchCategories(categoryIds);

      // Gắn thông tin danh mục cho từng hóa đơn
      for (var item in billItems) {
        String categoryId = item['categoryId'];
        var categoryInfo = categoryCache[categoryId] ??
            {
              'name': 'Không có tên',
              'icon': Icons.help_outline,
            };

        item['categoryName'] = categoryInfo['name'];
        item['categoryIcon'] = categoryInfo['icon'];
      }

      // Cập nhật state
      totalTransaction = totalAmount; // Tổng số tiền hóa đơn
      budgetItems = billItems; // Danh sách hóa đơn
      notifyListeners();
    } catch (e) {
      print("Error fetching bill data: $e");
    }
  }

  // Hàm phụ: Lấy thông tin danh mục
  Future<Map<String, Map<String, dynamic>>> _fetchCategories(
      Set<String> categoryIds) async {
    if (categoryIds.isEmpty) return {};

    QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
        .collection('categories')
        .doc('group_category')
        .collection('KhoanChi')
        .where(FieldPath.documentId, whereIn: categoryIds.toList())
        .get();

    return {
      for (var doc in categorySnapshot.docs)
        doc.id: doc.data() as Map<String, dynamic>
    };
  }

  // Hàm tải dữ liệu hóa đơn theo userId, dùng listener để tự động cập nhật UI
  Future<void> loadDataBill(String userId) async {
    try {
      // Tải dữ liệu hóa đơn
      FirebaseFirestore.instance
          .collection('bills') // Sử dụng collection bills
          .where('userId', isEqualTo: userId)
          .snapshots()
          .listen((snapshot) {
        billData = snapshot.docs.map((doc) {
          var data = doc.data();
          return {
            'billId': data['billId'] ?? '',
            'userId': data['userId'] ?? '',
            'categoryId': data['categoryId'] ?? '',
            'amount': data['amount'] ?? 0,
            'name': data['name'] ?? '',
            'dueDate':
                (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
            'frequency': data['frequency'] ?? 1,
            'status': data['status'] ?? false,
            'note': data['note'] ?? '',
          };
        }).toList();
        notifyListeners(); // Cập nhật giao diện khi dữ liệu thay đổi
      });
    } catch (e) {
      debugPrint('Lỗi khi tải dữ liệu hóa đơn: $e');
    }
  }

}
