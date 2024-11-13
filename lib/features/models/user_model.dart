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

  toJson() {
    return {
      "FullName": fullName,
      "Email": email,
      "Password": password,
    };
  }
}
