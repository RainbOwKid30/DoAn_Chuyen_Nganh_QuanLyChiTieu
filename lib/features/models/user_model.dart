// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserModel {
  final String? id;
  final String fullName;
  final String email;
  final String password;

  UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.password,
  });

  // Phương thức chuyển đổi đối tượng UserModel sang JSON để lưu vào Firestore
  Map<String, dynamic> toJson() {
    return {
      "FullName": fullName,
      "Email": email,
      "Password": password,
    };
  }

  // Phương thức từ JSON sang đối tượng UserModel để lấy từ Firestore
  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      fullName: json['FullName'] ?? '',
      email: json['Email'] ?? '',
      password: json['Password'] ?? '',
    );
  }
}
