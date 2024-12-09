import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quan_ly_chi_tieu/features/controllers/category_controller.dart';
import 'package:quan_ly_chi_tieu/features/models/data_category_expense_income.dart';
import 'home_page_new_item.dart'; // Import trang HomePageNewItem

class HomePageChonNhom extends StatefulWidget {
  const HomePageChonNhom({super.key});

  @override
  State<HomePageChonNhom> createState() => _HomePageChonNhomState();
}

class _HomePageChonNhomState extends State<HomePageChonNhom>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final CategoryController _categoryController = CategoryController();
  Color _indicatorColor = Colors.red;
  // Tạo danh sách động từ dữ liệu mặc định
  final List<Map<String, dynamic>> _khoanChi = List.from(dataChi);
  final List<Map<String, dynamic>> _khoanThu = List.from(dataThu);

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu khi màn hình khởi tạo
    _loadFirestoreData();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _indicatorColor = _tabController.index == 0 ? Colors.red : Colors.blue;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFirestoreData() async {
    final data = await _categoryController.fetchFirestoreData(dataChi, dataThu);
    setState(() {
      _khoanChi
        ..clear()
        ..addAll(data['KhoanChi']!);

      _khoanThu
        ..clear()
        ..addAll(data['KhoanThu']!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Chọn Nhóm",
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: _indicatorColor,
          tabs: const [
            Tab(text: "Khoản Chi"),
            Tab(text: "Khoản Thu"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGroupList(_khoanChi, Colors.red), // Hiển thị Khoản Chi
          _buildGroupList(_khoanThu, Colors.blue), // Hiển thị Khoản Thu
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final categoryType =
              _tabController.index == 0 ? "Khoản Chi" : "Khoản Thu";
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePageNewItem(categoryType: categoryType),
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
        final categoryType =
            _tabController.index == 0 ? "Khoản Chi" : "Khoản Thu";
        final group = groups[index];
        return ListTile(
          leading: Image.asset(
            'assets/images/${group['icon']}.png',
            width: 40,
          ),
          title: Text(group['name']),
          onTap: () {
            // Trả về icon, tên nhóm và loại khoản (Chi hoặc Thu)
            Navigator.pop(context, {
              'name': group['name'], // Tên nhóm
              'icon': group['icon'], // Icon nhóm
              'type': categoryType, // Loại khoản (Chi hoặc Thu)
            });
          },
        );
      },
    );
  }
}
