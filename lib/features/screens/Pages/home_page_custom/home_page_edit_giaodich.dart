import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_screen/custom_buildOptionRow.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_screen/custom_money.dart';
import 'package:quan_ly_chi_tieu/features/controllers/providers/Transaction_Provider.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_page_custom/home_page_chon_nhom.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_page_custom/home_page_ghichu.dart';

class HomePageEditGiaodich extends StatefulWidget {
  final Map<String, dynamic> data; // Nhận dữ liệu từ màn hình trước

  const HomePageEditGiaodich({super.key, required this.data});

  @override
  State<HomePageEditGiaodich> createState() => _HomePageEditGiaodichState();
}

class _HomePageEditGiaodichState extends State<HomePageEditGiaodich> {
  late TextEditingController _amountController; // Controller cho số tiền
  late String selectedGroupName; // Tên nhóm
  late String selectedGroupIcon; // Icon nhóm
  late String selectedGhiChu; // Ghi chú
  late DateTime selectedDate; // Ngày giao dịch
  late Color transactionColor; // Màu sắc theo loại giao dịch
  final User? firebaseUser = FirebaseAuth.instance.currentUser;
  String transactionType = 'Khoản Thu';
  @override
  void initState() {
    super.initState();
    // Khởi tạo dữ liệu từ widget.data
    _amountController = TextEditingController(
        text: CustomMoney().formatCurrencyTotalNoSymbol(widget.data['amount']));
    selectedGroupName = widget.data['group'];
    selectedGroupIcon = widget.data['icon'];
    selectedGhiChu = widget.data['note'];
    selectedDate = widget.data['date']; // Lấy dữ liệu kiểu DateTime
    transactionColor = widget.data['transactionType'] == 'Khoản Thu'
        ? Colors.blue
        : Colors.red;
  }

  void _saveTransaction() async {
    if (firebaseUser != null) {
      try {
        // Tìm document dựa trên docId trong dữ liệu giao dịch
        String transactionSubCollection =
            widget.data['transactionType'] == 'Khoản Chi'
                ? 'KhoanChi'
                : 'KhoanThu';
        String docId = widget.data['docId'];

        // Cập nhật giao dịch trên Firestore
        await FirebaseFirestore.instance
            .collection('transactions')
            .doc('groups_thu_chi') // Tài liệu nhóm
            .collection(transactionSubCollection) // Nhóm con
            .doc(docId) // Document ID
            .update({
          'amount':
              double.tryParse(_amountController.text.replaceAll(',', '')) ??
                  0.0,
          'group': selectedGroupName, // Tên nhóm
          'transactionType': widget.data['transactionType'], // Loại giao dịch
          'date': selectedDate, // Ngày giao dịch
          'note': selectedGhiChu, // Ghi chú
          'icon': selectedGroupIcon, // Icon nhóm
        });

        // Sau khi cập nhật, tải lại dữ liệu
        String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
        if (userId.isNotEmpty) {
          Provider.of<TransactionProvider>(context, listen: false)
              .loadData(userId);
        }

        // Hiển thị thông báo thành công
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'Thành công',
          desc: 'Giao dịch đã được cập nhật thành công!',
          btnOkOnPress: () {
            Navigator.pop(context); // Quay lại sau khi thành công
          },
        ).show();
      } catch (e) {
        // Hiển thị lỗi nếu xảy ra
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'Lỗi',
          desc: 'Không thể lưu giao dịch: $e',
          btnOkOnPress: () {},
        ).show();
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Hiển thị ngày hiện tại
      firstDate: DateTime(2000), // Giới hạn ngày bắt đầu
      lastDate: DateTime(2100), // Giới hạn ngày kết thúc
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked; // Cập nhật ngày được chọn
      });
    }
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Sửa thông tin giao dịch",
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
                      color: transactionColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Nhập số tiền',
                      labelStyle: TextStyle(
                        color: transactionColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: transactionColor,
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: transactionColor,
                          width: 2.0,
                        ),
                      ),
                    ),
                    // nhập số có dấu ,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      // Sử dụng TextInputFormatter để thêm dấu phẩy khi người dùng nhập
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        String newText = newValue.text.replaceAll(',','');
                        String formattedText = CustomMoney()
                            .formatCurrencyTotalNoSymbol(
                                double.tryParse(newText) ?? 0.0);
                        return newValue.copyWith(text: formattedText);
                      }),
                    ],
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
                onTap: _openChonNhom, // Hàm mở chọn nhóm
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
                text:
                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}", // Hiển thị ngày
                page: const SizedBox(),
                onTap: () => _selectDate(context), // Mở DatePicker
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: ElevatedButton(
              onPressed: _saveTransaction,
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
}
