import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_chi_tieu/features/controllers/providers/Transaction_Provider.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_screen/custom_buildOptionRow.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_screen/custom_money.dart';
import 'package:quan_ly_chi_tieu/features/models/user_model.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_main/home_page_budget.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_page_custom/home_page_select_budget.dart';

class HomePageAddBudget extends StatefulWidget {
  const HomePageAddBudget({super.key});

  @override
  State<HomePageAddBudget> createState() => _HomePageAddBudgetState();
}

class _HomePageAddBudgetState extends State<HomePageAddBudget> {
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

  // Date selection
  DateTime? selectedDate;

  // Hàm để tính toán ngày đầu và ngày cuối của tháng hiện tại
  void setCurrentMonthDates() {
    final DateTime now = DateTime.now();
    // First day of current month
    final DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    // Last day of current month
    final DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    setState(() {
      selectedDate = firstDayOfMonth; // Set the start date
    });

    // Update the start and end dates for the budget
    startDate = firstDayOfMonth;
    endDate = lastDayOfMonth;
  }

  DateTime startDate = DateTime.now(); // Ngày bắt đầu
  DateTime endDate = DateTime.now(); // Ngày kết thúc

  @override
  void initState() {
    super.initState();
    setCurrentMonthDates(); // Đặt ngày đầu và ngày cuối tháng khi mở màn hình
  }

  String budgetId = FirebaseFirestore.instance.collection('budgets').doc().id;
  void saveBudgets() async {
    if (firebaseUser != null) {
      try {
        // Lấy tất cả tài liệu từ collection 'categories' dưới 'group_category'
        QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
            .collection('categories')
            .doc('group_category')
            .collection('KhoanChi')
            .get();

        // Kiểm tra nếu có tài liệu trong collection
        if (categorySnapshot.docs.isNotEmpty) {
          // Giả sử bạn có danh sách các danh mục, và người dùng chọn nhóm cần lưu
          String categoryId = ''; // Khởi tạo categoryId

          // Duyệt qua tất cả các tài liệu trong categorySnapshot
          for (var doc in categorySnapshot.docs) {
            // Kiểm tra nếu tên nhóm trong danh mục trùng với nhóm người dùng đã chọn
            if (doc['name'] == selectedGroupName) {
              // 'name' là trường trong Firestore
              categoryId = doc.id; // Lấy docId của nhóm tương ứng
              break;
            }
          }

          // Nếu tìm thấy categoryId hợp lệ
          if (categoryId.isNotEmpty) {
            // Lưu dữ liệu vào Firestore với categoryId lấy từ tài liệu trong KhoanChi
            await FirebaseFirestore.instance
                .collection('budgets')
                .doc(budgetId)
                .set({
              'userId': firebaseUser!.uid,
              'categoryId':
                  categoryId, // Lưu categoryId lấy từ tài liệu trong KhoanChi
              'amount':
                  double.tryParse(_amountController.text.replaceAll(',', '')) ??
                      0.0,
              'startDate': startDate,
              'endDate': endDate,
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
          } else {
            // Nếu không tìm thấy danh mục hợp lệ
            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.rightSlide,
              title: 'Lỗi',
              desc: 'Không tìm thấy nhóm danh mục trùng khớp.',
              btnOkOnPress: () {},
            ).show();
          }
        } else {
          // Nếu không tìm thấy bất kỳ danh mục nào trong 'KhoanChi'
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.rightSlide,
            title: 'Lỗi',
            desc: 'Không có danh mục nào trong hệ thống.',
            btnOkOnPress: () {},
          ).show();
        }
      } catch (e) {
        // Xử lý lỗi nếu có
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'Lỗi',
          desc: 'Có lỗi khi lưu ngân sách: $e',
          btnOkOnPress: () {},
        ).show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format the start and end date
    String formattedDate =
        'This month (${DateFormat('d/MM').format(startDate)} - ${DateFormat('d/MM').format(endDate)})';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Thêm Ngân Sách",
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
                onTap: () => setCurrentMonthDates(),
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
                  btnOkOnPress: saveBudgets,
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
}
