// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String transactionType;
  final double amount;
  final String docId;
  final String group;
  final String icon;
  final DateTime date; // Ngày giao dịch

  TransactionModel({
    required this.amount,
    required this.docId,
    required this.group,
    required this.icon,
    required this.date,
    required this.transactionType,
  });

  // Phương thức chuyển từ map (khi lấy dữ liệu từ Firestore) sang đối tượng Transaction
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      // Nếu không có id thì gán là rỗng
      transactionType: map['transactionType'] ?? '',
      // Nếu không có amount thì gán mặc định là 0
      amount: map['amount'] ?? 0.0,
      docId: map['docId'] ?? '',
      group: map['group'] ?? '',
      icon: map['icon'] ?? '',
      // Chuyển đổi timestamp từ Firestore
      date: (map['date'] as Timestamp).toDate(),
    );
  }

  // Phương thức chuyển đối tượng Transaction thành map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'transactionType': transactionType,
      'amount': amount,
      'docId': docId,
      'group': group,
      'icon': icon,
      'date': date,
    };
  }
}
