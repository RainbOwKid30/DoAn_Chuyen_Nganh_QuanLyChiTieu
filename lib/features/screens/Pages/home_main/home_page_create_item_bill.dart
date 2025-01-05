import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_chi_tieu/features/controllers/providers/BillProvider.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_screen/custom_buildOptionRow.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_screen/custom_money.dart';
import 'package:quan_ly_chi_tieu/features/models/user_model.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_main/home_page_budget.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_page_custom/home_page_ghichu.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_page_custom/home_page_select_budget.dart';

class HomePageCreateItemBill extends StatefulWidget {
  const HomePageCreateItemBill({super.key});

  @override
  State<HomePageCreateItemBill> createState() => _HomePageCreateItemBillState();
}

class _HomePageCreateItemBillState extends State<HomePageCreateItemBill> {
  final User? firebaseUser = FirebaseAuth.instance.currentUser;
  String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
  UserModel? userModel;
  bool isEditingName = false;
  bool isEditingEmail = false;
  // Giá trị mặc định là thu
  String transactionType = 'Khoản Thu';
  // Màu mặc định cho thu (Xanh lá)
  Color transactionColor = Colors.green;
  final TextEditingController _amountController = TextEditingController();

  // Dữ liệu ghi chú thêm
  String selectedGhiChu = "Note";

  // Dữ liệu cho chọn nhóm
  String selectedGroupName = 'Select Category'; // Giá trị mặc định
  String selectedGroupIcon = 'question_mark'; // Icon mặc định
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

  // Hàm để mở HomePageChonNhom và lấy dữ liệu khi chọn item
  void _openChonNhom() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomePageSelectBudget()),
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

  // Date selection
  DateTime? selectedDate;
  DateTime? lastDate;
  String formattedDate = "This Month";
  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    // Bắt đầu từ hôm nay
    final DateTime firstDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);
    // Ngày cuối tháng hiện tại
    final lastDate = DateTime(currentDate.year, currentDate.month + 1, 0);
    final DateTime initialDate = selectedDate ??
        currentDate; // Sử dụng selectedDate nếu có, nếu không thì là currentDate

    // Đảm bảo initialDate không nhỏ hơn firstDate
    final DateTime selected = await showDatePicker(
          context: context,
          initialDate: initialDate.isBefore(firstDate)
              ? firstDate
              : initialDate, // Đặt initialDate hợp lệ
          firstDate: firstDate,
          lastDate: lastDate,
        ) ??
        currentDate; // Mặc định là currentDate nếu người dùng hủy

    setState(() {
      selectedDate = selected; // Cập nhật selectedDate với ngày người dùng chọn
      formattedDate =
          'This Month (${DateFormat('d/MM').format(selectedDate!)} - ${DateFormat('d/MM').format(lastDate)})';
    });
  }

  @override
  void initState() {
    super.initState();
  }

  String budgetId = FirebaseFirestore.instance.collection('budgets').doc().id;
  void saveBill() async {
    if (firebaseUser == null) return;

    try {
      // Kiểm tra nếu nhóm chưa được chọn hoặc số tiền chưa được nhập
      if (selectedGroupName == 'Select Category' ||
          _amountController.text.isEmpty) {
        _showErrorDialog('Vui lòng chọn nhóm và nhập số tiền.');
        return;
      }

      // Lấy tất cả tài liệu từ collection 'categories' dưới 'group_category'
      QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
          .collection('categories')
          .doc('group_category')
          .collection('KhoanChi')
          .get();

      if (categorySnapshot.docs.isNotEmpty) {
        // Tìm categoryId dựa trên selectedGroupName
        String categoryId = '';
        for (var doc in categorySnapshot.docs) {
          if (doc['name'] == selectedGroupName) {
            categoryId = doc.id;
            break;
          }
        }

        // Nếu không tìm thấy categoryId hợp lệ
        if (categoryId.isEmpty) {
          _showErrorDialog('Không tìm thấy nhóm danh mục trùng khớp.');
          return;
        }

        // Lấy giá trị cần thiết để lưu hóa đơn
        String billId = FirebaseFirestore.instance.collection('bills').doc().id;
        double amount =
            double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
        String name = selectedGroupName;
        DateTime dueDate = selectedDate ?? DateTime.now();
        int frequency = 1; // Tần suất mặc định là 1 lần
        bool status = false; // Trạng thái mặc định là chưa thanh toán

        // Lưu hóa đơn vào Firestore
        await FirebaseFirestore.instance.collection('bills').doc(billId).set({
          'billId': billId,
          'userId': firebaseUser!.uid,
          'categoryId': categoryId,
          'amount': amount,
          'name': name,
          'dueDate': dueDate,
          'frequency': frequency,
          'status': status,
          'note': selectedGhiChu,
        });
        // Sau khi lưu hóa đơn thành công, tải lại dữ liệu
        final billProvider = Provider.of<Billprovider>(context, listen: false);
        billProvider.fetchBillData();
        // Hiển thị thông báo thành công và quay lại trang trước
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'Thành công',
          desc: 'Hóa đơn đã được lưu.',
          btnOkOnPress: () {
            // Sau khi lưu xong, tải lại dữ liệu

            if (userId.isNotEmpty) {
              // Gọi lại loadData để tải dữ liệu mới từ Firestore
              Provider.of<Billprovider>(context, listen: false)
                  .loadDataBill(userId); // Gọi lại loadData để tải dữ liệu mới
            }
            Navigator.pop(context);
          },
        ).show();
      } else {
        _showErrorDialog('Không có danh mục nào trong hệ thống.');
      }
    } catch (e) {
      _showErrorDialog('Có lỗi khi lưu hóa đơn: $e');
    }
  }

  void _showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: 'Lỗi',
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    // Format the start and end date
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Create Bill",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          color: const Color(0xff000000),
          icon: const Icon(FontAwesomeIcons.xmark),
          onPressed: () {
            Navigator.pop(context, true); // Quay lại trang trước
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
                page: const HomePageSelectBudget(),
                onTap: _openChonNhom,
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
                onTap: () => _selectDueDate(context),
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
                saveBill();
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
}
