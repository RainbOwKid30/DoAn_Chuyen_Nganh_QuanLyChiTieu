import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryController {
  Future<Map<String, List<Map<String, dynamic>>>> fetchFirestoreData(
      List<Map<String, dynamic>> defaultChi,
      List<Map<String, dynamic>> defaultThu) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final Map<String, List<Map<String, dynamic>>> result = {
      'KhoanChi': List.from(defaultChi),
      'KhoanThu': List.from(defaultThu),
    };

    if (userId != null) {
      try {
        // Lấy dữ liệu Khoản Chi
        final chiSnapshot = await FirebaseFirestore.instance
            .collection('categories')
            .doc("group_category")
            .collection('KhoanChi')
            .get();

        // Lấy dữ liệu Khoản Thu
        final thuSnapshot = await FirebaseFirestore.instance
            .collection('categories')
            .doc("group_category")
            .collection('KhoanThu')
            .get();

        // Cập nhật dữ liệu
        result['KhoanChi']
          ?..clear()
          ..addAll(defaultChi)
          ..addAll(chiSnapshot.docs.map((doc) => doc.data()));

        result['KhoanThu']
          ?..clear()
          ..addAll(defaultThu)
          ..addAll(thuSnapshot.docs.map((doc) => doc.data()));
      } catch (e) {
        print('Lỗi khi tải dữ liệu Firestore: $e');
      }
    }

    return result;
  }
}
