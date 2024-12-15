import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_screen/custom_buildOptionRow.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_screen/custom_money.dart';
import 'package:quan_ly_chi_tieu/features/models/user_model.dart';
import 'package:quan_ly_chi_tieu/features/controllers/providers/Transaction_Provider.dart';
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
  String selectedGroupName = 'Select Category'; // Giá trị mặc định
  String selectedGroupIcon = 'question_mark'; // Icon mặc định

  // Dữ liệu ghi chú thêm
  String selectedGhiChu = "Note";

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
      String categoryId = '';
      try {
        // Truy vấn cả hai collection để tìm selectedGroupName
        QuerySnapshot khoanChiSnapshot = await FirebaseFirestore.instance
            .collection('categories')
            .doc('group_category')
            .collection('KhoanChi')
            .where('name', isEqualTo: selectedGroupName)
            .get();

        QuerySnapshot khoanThuSnapshot = await FirebaseFirestore.instance
            .collection('categories')
            .doc('group_category')
            .collection('KhoanThu')
            .where('name', isEqualTo: selectedGroupName)
            .get();

        // Kiểm tra nếu có tài liệu trong collection
        if (khoanChiSnapshot.docs.isNotEmpty) {
          // Duyệt qua tất cả các tài liệu trong categorySnapshot
          for (var doc in khoanChiSnapshot.docs) {
            // Kiểm tra nếu tên nhóm trong danh mục trùng với nhóm người dùng đã chọn
            if (doc['name'] == selectedGroupName) {
              // 'name' là trường trong Firestore
              categoryId = doc.id; // Lấy docId của nhóm tương ứng
              break;
            }
          }
        } else if (khoanThuSnapshot.docs.isNotEmpty) {
          // Duyệt qua tất cả các tài liệu trong categorySnapshot
          for (var doc in khoanThuSnapshot.docs) {
            // Kiểm tra nếu tên nhóm trong danh mục trùng với nhóm người dùng đã chọn
            if (doc['name'] == selectedGroupName) {
              // 'name' là trường trong Firestore
              categoryId = doc.id; // Lấy docId của nhóm tương ứng
              break;
            }
          }
        }
        // Chọn nhóm giao dịch, tùy thuộc vào loại giao dịch
        String transactionSubCollection =
            transactionType == 'Khoản Chi' ? 'KhoanChi' : 'KhoanThu';

        // Lưu giao dịch vào Firestore
        var docRef = await FirebaseFirestore.instance
            .collection('transactions')
            .doc('groups_thu_chi') // Tạo tài liệu nhóm
            .collection(
                transactionSubCollection) // Chọn nhóm con theo loại giao dịch
            .add({
          'userId': firebaseUser!.uid, // ID người dùng
          'amount':
              double.tryParse(_amountController.text.replaceAll(',', '')) ??
                  0.0,
          'group': selectedGroupName, // Tên nhóm
          'transactionType': transactionType, // Loại giao dịch (thu/chi)
          'categoryId': categoryId,
          'date': selectedDate ?? DateTime.now(), // Ngày giao dịch
          'note': selectedGhiChu, // Ghi chú
          'icon': selectedGroupIcon,
        });

        // Lưu docId vào tài liệu giao dịch
        await docRef.update({
          'docId': docRef.id, // Lưu docId vào tài liệu
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
          title: const Text("Note"),
          content: TextField(
            controller: noteController,
            maxLength: 100, // Giới hạn 100 ký tự
            decoration: const InputDecoration(
              hintText: "Input Note",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng dialog mà không lưu
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedGhiChu = noteController.text.isEmpty
                      ? "Note"
                      : noteController.text;
                });
                Navigator.pop(context); // Đóng dialog
              },
              child: const Text("Save"),
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
        : 'Day / Month / Year';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Add Transaction",
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
                      labelText: 'Input Amount',
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
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      // Sử dụng TextInputFormatter để thêm dấu phẩy khi người dùng nhập
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        String newText = newValue.text.replaceAll(',', '');
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
                const Text("Cash"),
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
                'Save',
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
