import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_buildOptionRow.dart';
import 'package:quan_ly_chi_tieu/features/models/user_model.dart';
import 'package:quan_ly_chi_tieu/features/providers/Transaction_Provider.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_main/home_page_budget.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_page_custom/home_page_chon_nhom.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_page_custom/home_page_ghichu.dart';

class HomePagePlus extends StatefulWidget {
  const HomePagePlus({super.key});

  @override
  State<HomePagePlus> createState() => _HomePagePlusState();
}

class _HomePagePlusState extends State<HomePagePlus> {
  final User? firebaseUser = FirebaseAuth.instance.currentUser;
  UserModel? userModel;
  bool isEditingName = false;
  bool isEditingEmail = false;
  // Giá trị mặc định là thu
  String transactionType = 'Khoản Thu';
  // Màu mặc định cho thu (Xanh lá)
  Color transactionColor = Colors.green;
  final TextEditingController _amountController = TextEditingController();

  // Dữ liệu cho chọn nhóm
  String selectedGroupName = 'Chọn nhóm'; // Giá trị mặc định
  String selectedGroupIcon = 'question_mark'; // Icon mặc định

  // Dữ liệu ghi chú thêm
  String selectedGhiChu = "Ghi chú thêm";

  // Date selection
  DateTime? selectedDate;

  // Function to open date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? currentDate,
          firstDate: DateTime(currentDate.year),
          lastDate: DateTime(2100),
        ) ??
        currentDate;

    setState(() {
      selectedDate = pickedDate;
    });
  }

  void _saveTransaction() async {
    if (firebaseUser != null) {
      try {
        // Chọn nhóm giao dịch, tùy thuộc vào loại giao dịch
        String transactionSubCollection =
            transactionType == 'Khoản Chi' ? 'KhoanChi' : 'KhoanThu';

        // Lưu giao dịch vào Firestore
        await FirebaseFirestore.instance
            .collection('transactions')
            .doc('groups_thu_chi') // Tạo tài liệu nhóm
            .collection(
                transactionSubCollection) // Chọn nhóm con theo loại giao dịch
            .add({
          'userId': firebaseUser!.uid, // ID người dùng
          'amount': int.tryParse(_amountController.text) ?? 0, // Số tiền
          'group': selectedGroupName, // Tên nhóm
          'transactionType': transactionType, // Loại giao dịch (thu/chi)
          'date': selectedDate ?? DateTime.now(), // Ngày giao dịch
          'note': selectedGhiChu, // Ghi chú
        });

        // Sau khi lưu xong, tải lại dữ liệu
        String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
        if (userId.isNotEmpty) {
          // Gọi lại loadData để tải dữ liệu mới từ Firestore
          Provider.of<TransactionProvider>(context, listen: false)
              .loadData(userId); // Gọi lại loadData để tải dữ liệu mới
        }

        // Quay lại trang trước sau khi lưu thành công
        Navigator.pop(context);
      } catch (e) {
        // Xử lý lỗi nếu có
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'Lỗi',
          desc: 'Có lỗi khi lưu giao dịch: $e',
          btnOkOnPress: () {},
        ).show();
      }
    }
  }

  void _openGhichuDialog() async {
    final TextEditingController noteController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ghi chú thêm"),
          content: TextField(
            controller: noteController,
            maxLength: 100, // Giới hạn 100 ký tự
            decoration: const InputDecoration(
              hintText: "Nhập ghi chú",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng dialog mà không lưu
              },
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedGhiChu = noteController.text.isEmpty
                      ? "Thêm ghi chú"
                      : noteController.text;
                });
                Navigator.pop(context); // Đóng dialog
              },
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(selectedDate!)
        : 'Ngày / Tháng / Năm';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Thêm Giao Dịch",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          color: const Color(0xff000000),
          icon: const Icon(FontAwesomeIcons.xmark),
          onPressed: () {
            Navigator.pop(context); // Quay lại trang trước
          },
        ),
      ),
      body: Column(
        children: [
          // đường kẻ
          const Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Divider(
              thickness: 1,
              color: Color(0xFFb7b7b7),
            ),
          ),
          const SizedBox(height: 20),
          // Input Money
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Row(
              children: [
                Image.asset(
                  "assets/images/moneyroll.png",
                  width: 30,
                ),
                const SizedBox(width: 25),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      // Sử dụng màu động cho số tiền nhập vào
                      color: transactionColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Nhập số tiền',
                      labelStyle: TextStyle(
                        color: transactionColor, // Màu label động
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: transactionColor, // Màu viền động
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: transactionColor, // Màu viền động khi focus
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomBuildoptionrow(
                context1: context,
                icon: Image.asset(
                  'assets/images/$selectedGroupIcon.png',
                  width: 30,
                  height: 30,
                ),
                text: selectedGroupName,
                page: const HomePageChonNhom(),
                onTap: _openChonNhom,
              ),
              CustomBuildoptionrow(
                context1: context,
                icon: Image.asset(
                  'assets/images/homework.png',
                  width: 30,
                  height: 30,
                ),
                text: selectedGhiChu,
                page: const HomePageGhichu(),
                onTap: _openGhichuDialog,
              ),
              CustomBuildoptionrow(
                context1: context,
                icon: Image.asset(
                  'assets/images/schedule.png',
                  width: 30,
                  height: 30,
                ),
                text: formattedDate,
                page: const HomePageBudget(),
                onTap: () => _selectDate(context),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 15.0),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/wallet.png',
                  width: 30,
                  height: 30,
                ),
                const SizedBox(
                  width: 20,
                ),
                const Text("Tiền mặt"),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
          ),
          // Đẩy nút "Lưu" xuống cuối màn hình
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: ElevatedButton(
              onPressed: () {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.success,
                  animType: AnimType.rightSlide,
                  title: 'Đã thêm giao dịch mới',
                  btnOkOnPress: _saveTransaction,
                ).show();
              },
              style: ElevatedButton.styleFrom(
                // Độ rộng đầy đủ
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Lưu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm để mở HomePageChonNhom và lấy dữ liệu khi chọn item
  void _openChonNhom() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomePageChonNhom()),
    );

    if (result != null) {
      setState(() {
        // Cập nhật tên nhóm và icon
        selectedGroupName = result['name'];
        selectedGroupIcon = result['icon'];

        // Cập nhật loại khoản (thu/chi)
        transactionType = result['type']; // Giả sử 'type' là thu hoặc chi

        // Cập nhật màu sắc dựa trên loại khoản
        transactionColor =
            (transactionType == 'Khoản Chi') ? Colors.red : Colors.blue;
      });
    }
  }
}
