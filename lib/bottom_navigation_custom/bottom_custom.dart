import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_main/home_page_account.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_main/home_page_budget.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_main/home_page_plus.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_main/home_page_thu_chi.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_main/home_page_transaction.dart';

class BottomNavigationCustom extends StatefulWidget {
  const BottomNavigationCustom({super.key});

  @override
  State<BottomNavigationCustom> createState() => _BottomNavigationCustomState();
}

class _BottomNavigationCustomState extends State<BottomNavigationCustom> {
  int activePage = 0;

  List<Widget> listPage = [
    const HomePageThuChi(),
    const HomePageTransaction(),
    const HomePagePlus(),
    const HomePageBudget(),
    const HomePageAccount(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: listPage[activePage],
      bottomNavigationBar: Container(
        color: const Color(0xFFFFFFFF),
        // Thêm padding cho thanh điều hướng
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon Home
            _buildBottomNavItem(
              icon: CupertinoIcons.home,
              label: 'Tổng quan',
              index: 0,
            ),
            // Icon Transaction
            _buildBottomNavItem(
              icon: FontAwesomeIcons.wallet,
              label: 'Sổ giao dịch',
              index: 1,
            ),
            // Nút cộng
            Container(
              width: 50, // Đặt width cố định cho nút
              height: 50, // Đặt height cố định cho nút
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 10, 200, 7), // Màu nền
                shape: BoxShape.circle, // Đặt hình dạng là hình tròn
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // Màu bóng
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // Đặt vị trí bóng
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HomePagePlus()),
                  );
                },
                backgroundColor:
                    Colors.transparent, // Đặt màu nền là trong suốt
                elevation: 0, // Đặt độ nổi là 0
                child: const Icon(
                  FontAwesomeIcons.plus,
                  size: 20,
                  color: Colors.white, // Màu icon
                ),
              ),
            ),
            // Icon Budget
            _buildBottomNavItem(
              icon: FontAwesomeIcons.chartPie,
              label: 'Ngân Sách',
              index: 3,
            ),
            // Icon Account
            _buildBottomNavItem(
              icon: FontAwesomeIcons.user,
              label: 'Tài khoản',
              index: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
      {required IconData icon, required String label, required int index}) {
    return InkWell(
      child: GestureDetector(
        onTap: () {
          setState(() {
            activePage = index > 2 ? index : index; // Điều chỉnh chỉ số nếu cần
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: activePage == index ? Colors.black : Colors.grey),
            Text(
              label,
              style: TextStyle(
                  color: activePage == index ? Colors.black : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
