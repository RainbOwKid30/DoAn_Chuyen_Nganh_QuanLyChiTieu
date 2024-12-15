import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_chi_tieu/features/controllers/providers/BudgetProvider.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_screen/custom_buildOptionRow.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_screen/custom_money.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_page_custom/home_page_chon_nhom.dart';

class HomePageEditBudget extends StatefulWidget {
  final Map<String, dynamic> data; // Nhận dữ liệu từ màn hình trước

  const HomePageEditBudget({super.key, required this.data});

  @override
  State<HomePageEditBudget> createState() => _HomePageEditBudgetState();
}

class _HomePageEditBudgetState extends State<HomePageEditBudget> {
  late TextEditingController _amountController; // Controller cho số tiền
  late String selectedGroupName; // Tên nhóm
  late String selectedGroupIcon; // Icon nhóm
  late String selectedGhiChu; // Ghi chú
  final User? firebaseUser = FirebaseAuth.instance.currentUser;
  String transactionType = 'Khoản Thu';

  DateTime startDate = DateTime.now(); // Ngày bắt đầu
  DateTime endDate = DateTime.now(); // Ngày kết thúc

  @override
  void initState() {
    super.initState();

    // Khởi tạo dữ liệu từ widget.data
    _amountController = TextEditingController(
        text: CustomMoney().formatCurrencyTotalNoSymbol(widget.data['amount']));
    selectedGroupName = widget.data['category'];
    selectedGroupIcon = widget.data['icon'];
    // Set initial dates from widget data
    startDate = widget.data['startDate'].toDate();
    endDate = widget.data['endDate'].toDate();
  }

  Future<void> _selectStartAndEndDate(BuildContext context) async {
    // Hiển thị dialog chọn cả ngày bắt đầu và kết thúc
    final result = await showDialog<Map<String, DateTime>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chọn ngày bắt đầu và kết thúc'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Chọn ngày bắt đầu
                ListTile(
                  title: const Text('Chọn ngày bắt đầu'),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy').format(startDate),
                  ),
                  onTap: () async {
                    final DateTime? pickedStart = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedStart != null && pickedStart != startDate) {
                      setState(() {
                        startDate = pickedStart;
                      });
                    }
                  },
                ),
                // Chọn ngày kết thúc
                ListTile(
                  title: const Text('Chọn ngày kết thúc'),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy').format(endDate),
                  ),
                  onTap: () async {
                    final DateTime? pickedEnd = await showDatePicker(
                      context: context,
                      initialDate: endDate,
                      firstDate: startDate,
                      lastDate: DateTime(2101),
                    );
                    if (pickedEnd != null && pickedEnd != endDate) {
                      setState(() {
                        endDate = pickedEnd;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                    context, {'startDate': startDate, 'endDate': endDate});
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );

    // Nếu có giá trị trả về từ dialog, cập nhật lại giá trị cho các ngày
    if (result != null) {
      setState(() {
        startDate = result['startDate']!;
        endDate = result['endDate']!;
      });
    }
  }

  void saveBudgets() async {
    if (firebaseUser == null) return;

    try {
      // Lấy tất cả tài liệu từ collection 'categories' dưới 'group_category'
      QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
          .collection('categories')
          .doc('group_category')
          .collection('KhoanChi')
          .get();

      // Kiểm tra nếu có tài liệu trong collection
      if (categorySnapshot.docs.isNotEmpty) {
        // Khởi tạo categoryId
        String categoryId = '';

        // Duyệt qua các tài liệu trong categorySnapshot
        for (var doc in categorySnapshot.docs) {
          if (doc['name'] == selectedGroupName) {
            categoryId = doc.id; // Lấy docId của nhóm phù hợp
            break;
          }
        }

        // Nếu tìm thấy categoryId hợp lệ
        if (categoryId.isNotEmpty) {
          // Lưu dữ liệu vào Firestore
          await FirebaseFirestore.instance
              .collection('budgets')
              .doc(widget.data['id']) // Sử dụng ID ngân sách đã có
              .update({
            'categoryId': categoryId, // Lưu categoryId từ tài liệu KhoanChi
            'amount':
                double.tryParse(_amountController.text.replaceAll(',', '')) ??
                    0.0, // Lưu số tiền đã định dạng
            'startDate': startDate,
            'endDate': endDate,
          });

          // Sau khi lưu xong, tải lại dữ liệu ngay lập tức
          final budgetProvider =
              Provider.of<BudgetProvider>(context, listen: false);
          // Cập nhật lại dữ liệu ngân sách
          await budgetProvider.fetchBudgetData();

          setState(() {}); // Cập nhật UI

          // Quay lại trang trước sau khi lưu thành công
          Navigator.pop(context);
        } else {
          _showErrorDialog('Không tìm thấy nhóm danh mục trùng khớp.');
        }
      } else {
        _showErrorDialog('Không có danh mục nào trong hệ thống.');
      }
    } catch (e) {
      _showErrorDialog('Có lỗi khi lưu ngân sách: $e');
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        'This month (${DateFormat('d/MM').format(startDate)} - ${DateFormat('d/MM').format(endDate)})';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Edit Budget",
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Input Amount',
                      labelStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                        ),
                      ),
                    ),
                    // nhập số có dấu ,
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
                onTap: _openChonNhom, // Hàm mở chọn nhóm
              ),
              CustomBuildoptionrow(
                context1: context,
                icon: Image.asset(
                  'assets/images/schedule.png',
                  width: 30,
                  height: 30,
                ),
                text: formattedDate,
                page: const HomePageChonNhom(),
                onTap: () => _selectStartAndEndDate(context),
              ),
            ],
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
            child: ElevatedButton(
              onPressed: saveBudgets,
              style: ElevatedButton.styleFrom(
                // Độ rộng đầy đủ
                minimumSize: const Size(double.infinity, 40),
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
