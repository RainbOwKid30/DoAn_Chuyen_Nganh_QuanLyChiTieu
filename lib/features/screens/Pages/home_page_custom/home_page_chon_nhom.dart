import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quan_ly_chi_tieu/features/models/json/data_chi.dart';
import 'package:quan_ly_chi_tieu/features/models/json/data_thu.dart';
import 'home_page_new_item.dart'; // Import trang HomePageNewItem

class HomePageChonNhom extends StatefulWidget {
  const HomePageChonNhom({super.key});

  @override
  State<HomePageChonNhom> createState() => _HomePageChonNhomState();
}

class _HomePageChonNhomState extends State<HomePageChonNhom>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Color _indicatorColor = Colors.red;
  // Tạo danh sách động từ dữ liệu mặc định
  final List<Map<String, dynamic>> _khoanChi = List.from(dataChi);
  final List<Map<String, dynamic>> _khoanThu = List.from(dataThu);

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu khi màn hình khởi tạo
    _fetchFirestoreData();
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

  Future<void> _fetchFirestoreData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
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

        setState(() {
          // Cập nhật dữ liệu Khoản Chi
          _khoanChi
            ..clear()
            ..addAll(dataChi) // Thêm dữ liệu mặc định
            ..addAll(chiSnapshot.docs.map((doc) => doc.data()));

          // Cập nhật dữ liệu Khoản Thu
          _khoanThu
            ..clear()
            ..addAll(dataThu) // Thêm dữ liệu mặc định
            ..addAll(thuSnapshot.docs.map((doc) => doc.data()));
        });
      } catch (e) {
        print('Lỗi khi tải dữ liệu Firestore: $e');
      }
    }
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
            _fetchFirestoreData(); // Reload dữ liệu sau khi thêm mới
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
