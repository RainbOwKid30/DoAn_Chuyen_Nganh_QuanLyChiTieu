import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_main/home_page_budget.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_welcome/home_page_welcome.dart';

class HomePageAccount extends StatelessWidget {
  const HomePageAccount({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin người dùng hiện tại từ Firebase
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 15.0),
          // Tiêu đề trang
          const Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20.0, top: 15, bottom: 15),
                child: Text(
                  "Tài khoản",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const Divider(
            thickness: 1,
            color: Color(0xFFb7b7b7),
          ),
          // Avatar người dùng
          Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: CircleAvatar(
                      radius: 80,
                      // Hiển thị ảnh đại diện từ Firebase
                      backgroundImage: NetworkImage(
                        user?.photoURL ??
                            'https://static.vecteezy.com/system/resources/previews/019/896/008/original/male-user-avatar-icon-in-flat-design-style-person-signs-illustration-png.png',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Tên người dùng (hiển thị nếu có)
              Text(
                user?.displayName ?? "Tên người dùng chưa cập nhật",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              // Email người dùng
              Text(
                user?.email ?? "Email chưa cập nhật",
                style: const TextStyle(
                  color: Color(0xFFb7b7b7),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          // Các nút chức năng
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildOptionRow(
                context,
                FontAwesomeIcons.wallet,
                "Ví của tôi",
                const HomePageBudget(),
              ),
              _buildOptionRow(
                context,
                FontAwesomeIcons.boxesStacked,
                "Nhóm",
                const HomePageBudget(),
              ),
              _buildOptionRow(
                context,
                FontAwesomeIcons.fileInvoice,
                "Hóa đơn",
                const HomePageBudget(),
              ),
              _buildOptionRow(
                context,
                FontAwesomeIcons.toolbox,
                "Công cụ",
                const HomePageBudget(),
              ),
              _buildOptionRow(
                context,
                FontAwesomeIcons.cogs,
                "Cài đặt",
                const HomePageBudget(),
              ),
            ],
          ),
          // Nút đăng xuất
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton(
              onPressed: () async {
                // Đăng xuất người dùng
                await FirebaseAuth.instance.signOut();

                // Kiểm tra người dùng đã đăng xuất thành công chưa
                User? user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  // Người dùng đã đăng xuất thành công
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đăng xuất thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Điều hướng trở lại màn hình đăng nhập
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HomePageWelcome()),
                    (route) => false, // Xóa tất cả các màn hình trước đó
                  );
                } else {
                  // Người dùng chưa đăng xuất, có thể xảy ra lỗi
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đăng xuất thất bại'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEDEDED),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm tiện ích để tạo từng dòng chức năng
  Widget _buildOptionRow(
      BuildContext context, IconData icon, String text, Widget page) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Ink(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 20),
              Text(text),
              const Spacer(),
              const Icon(FontAwesomeIcons.angleRight),
            ],
          ),
        ),
      ),
    );
  }
}
