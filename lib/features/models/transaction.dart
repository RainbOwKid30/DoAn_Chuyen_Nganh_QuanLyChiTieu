import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction1 {
  final String id; // Mã ID giao dịch
  final String? description; // Mô tả giao dịch, có thể là null
  final double amount; // Số tiền giao dịch
  final DateTime date; // Ngày giao dịch
  final String type; // Loại giao dịch (thu, chi)

  // Constructor
  Transaction1({
    required this.id,
    this.description,  // Chấp nhận description có thể là null
    required this.amount,
    required this.date,
    required this.type,
  });

  // Phương thức chuyển từ map (khi lấy dữ liệu từ Firestore) sang đối tượng Transaction
  factory Transaction1.fromMap(Map<String, dynamic> map) {
    return Transaction1(
      id: map['id'] ?? '', // Nếu không có id thì gán là rỗng
      description: map['description'], // description có thể là null
      amount: map['amount'] ?? 0.0, // Nếu không có amount thì gán mặc định là 0
      date: (map['date'] as Timestamp).toDate(), // Chuyển đổi timestamp từ Firestore
      type: map['type'] ?? '', // Nếu không có type thì gán là rỗng
    );
  }

  // Phương thức chuyển đối tượng Transaction thành map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description ?? '', // Nếu description là null thì lưu rỗng
      'amount': amount,
      'date': date,
      'type': type,
    };
  }
}
