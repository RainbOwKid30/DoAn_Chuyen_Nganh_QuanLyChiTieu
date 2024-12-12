import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quan_ly_chi_tieu/features/controllers/category_controller.dart';
import 'package:quan_ly_chi_tieu/features/models/data_category_expense_income.dart';
import 'home_page_new_item.dart'; // Import trang HomePageNewItem

class HomePageSelectBudget extends StatefulWidget {
  const HomePageSelectBudget({super.key});

  @override
  State<HomePageSelectBudget> createState() => _HomePageSelectBudgetState();
}

class _HomePageSelectBudgetState extends State<HomePageSelectBudget> {
  final CategoryController _categoryController = CategoryController();
  final Color _indicatorColor = Colors.red;
  // Tạo danh sách động từ dữ liệu mặc định
  final List<Map<String, dynamic>> _khoanChi = List.from(dataChi);

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu khi màn hình khởi tạo
    _loadFirestoreData();
  }

  Future<void> _loadFirestoreData() async {
    final data = await _categoryController.fetchFirestoreData(dataChi, []);
    setState(() {
      _khoanChi
        ..clear()
        ..addAll(data['KhoanChi']!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Chọn Category",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          color: const Color(0xff000000),
          icon: const Icon(FontAwesomeIcons.angleLeft),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Divider(
            color: Colors.red,
            thickness: 2.0,
          ),
        ),
      ),
      body:
          _buildGroupList(_khoanChi, Colors.red), // Hiển thị Khoản Chi duy nhất
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          const categoryType = "Khoản Chi";
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const HomePageNewItem(categoryType: categoryType),
            ),
          );

          if (result == true) {
            _loadFirestoreData(); // Reload dữ liệu sau khi thêm mới
          }
        },
        backgroundColor: _indicatorColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGroupList(List<Map<String, dynamic>> groups, Color color) {
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return ListTile(
          leading: Image.asset(
            'assets/images/${group['icon']}.png',
            width: 40,
          ),
          title: Text(group['name']),
          onTap: () {
            // Trả về icon, tên nhóm và loại khoản (Chi)
            Navigator.pop(context, {
              'name': group['name'], // Tên nhóm
              'icon': group['icon'], // Icon nhóm
              'type': "Khoản Chi", // Loại khoản (Chi)
            });
          },
        );
      },
    );
  }
}
