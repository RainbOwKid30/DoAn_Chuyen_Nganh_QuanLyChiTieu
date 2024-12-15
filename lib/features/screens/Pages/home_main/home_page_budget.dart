import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_chi_tieu/features/controllers/providers/BudgetProvider.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_screen/custom_money.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_page_custom/home_page_add_budget.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_page_custom/home_page_edit_budget.dart';

class HomePageBudget extends StatefulWidget {
  const HomePageBudget({super.key});

  @override
  State<HomePageBudget> createState() => _HomePageBudgetState();
}

class _HomePageBudgetState extends State<HomePageBudget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  double totalBudget = 0; // Tổng ngân sách
  double spent = 0; // Số tiền đã chi
  double sotienconlai = 0; // Số tiền còn lại
  bool isLoading = true; // Trạng thái tải dữ liệu

  List<Map<String, dynamic>> budgetItems = [];
  Map<String, Map<String, dynamic>> categoryIcons = {};

  @override
  void initState() {
    super.initState();

    // Khởi tạo AnimationController và Tween
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Thời gian hiệu ứng
    );

    // Tạo một Tween từ 0 đến giá trị chi tiêu
    _progressAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Cập nhật giá trị cho thanh tiến trình
    _animationController.addListener(() {
      setState(() {});
    });

    // Bắt đầu animation
    _startAnimation();

    // Lấy dữ liệu ngân sách từ BudgetProvider
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    budgetProvider.fetchBudgetData().then((_) {
      setState(() {
        totalBudget = budgetProvider.totalBudget;
        spent = budgetProvider.spent;
        sotienconlai = budgetProvider.sotienconlai;
      });
      _startAnimation(); // Bắt đầu animation khi dữ liệu đã có
    });
  }

  // Hàm bắt đầu animation với giá trị progress mới
  void _startAnimation() {
    if (totalBudget == 0) {
      _progressAnimation = Tween<double>(begin: 0, end: 0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
    } else {
      double progress = spent / totalBudget; // Tính toán tỷ lệ chi tiêu
      _progressAnimation = Tween<double>(begin: 0, end: progress).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
    }
    // Đảm bảo animation bắt đầu lại từ đầu
    _animationController.forward(from: 0);
  }

  Future<void> deleteItem(String docId) async {
    try {
      // Xóa giao dịch từ Firestore dựa trên docId
      await FirebaseFirestore.instance
          .collection('budgets')
          .doc(docId) // Xóa tài liệu dựa trên docId
          .delete();
      print("Đã xóa giao dịch thành công");
    } catch (e) {
      print("Lỗi khi xóa tài liệu: $e");
    }
  }

  void showOptionsDialog(BuildContext context, Map<String, dynamic> budgetItem,
      Function onDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Option"),
          content: Container(
            width: 50.0,
            height: 50.0,
            decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              color: Color(0x00ffffff),
              borderRadius: BorderRadius.all(Radius.circular(1.0)),
            ),
            child: const Text("Do you want to DELETE or EDIT?"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePageEditBudget(
                      data: budgetItem, // Truyền dữ liệu item qua đây
                    ),
                  ),
                );
              },
              child: const Text("EDIT"),
            ),
            TextButton(
              onPressed: () async {
                // Xóa khỏi Firestore
                await deleteItem(budgetItem['id']);
                onDelete(); // Xóa khỏi danh sách hiển thị
                Navigator.pop(context);
              },
              child: const Text(
                "DELETE",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildTabBarView();
  }

  Widget _buildTabBarView() {
    final screenWidth = MediaQuery.of(context).size.width;
    const currentMonthLabel = "This month";

    return DefaultTabController(
      length: 1, // Số lượng tab
      child: Scaffold(
        backgroundColor: const Color(0xFFD0CBCB),
        appBar: AppBar(
          title: const Center(
            child: Text(
              "Total Budget",
              style: TextStyle(
                color: Color(0xFF000000),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: currentMonthLabel), // Tab tháng hiện tại
            ],
            labelColor: Colors.black,
          ),
        ),
        body: Consumer<BudgetProvider>(
          builder: (context, budgetProvider, child) {
            return TabBarView(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: screenWidth,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                // Thanh Timeline - LinearProgressIndicator
                                Column(
                                  children: [
                                    Text(
                                      "Percentage of spending (${(_progressAnimation.value * 100).toStringAsFixed(1)}%)",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 115, 114, 114),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    LinearProgressIndicator(
                                      value: _progressAnimation.value,
                                      backgroundColor: Colors.grey.shade300,
                                      color:
                                          const Color.fromARGB(255, 22, 98, 24),
                                      minHeight: 10,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Dòng số tiền còn lại
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "The remaining amount you can spend",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                              255, 147, 145, 145)),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Dòng số tiền chính
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      CustomMoney().formatCurrency(
                                          budgetProvider.sotienconlai),
                                      style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Dòng thông tin tổng ngân sách và đã chi
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          CustomMoney()
                                              .formatCurrencyTotalQuyDoi(
                                                  budgetProvider.totalBudget),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Text(
                                          "Total Budget",
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 115, 114, 114),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 20),
                                    Container(
                                      width: 2,
                                      height: 50,
                                      color: const Color.fromARGB(
                                          255, 115, 114, 114),
                                    ),
                                    const SizedBox(width: 20),
                                    Column(
                                      children: [
                                        Text(
                                          CustomMoney()
                                              .formatCurrencyTotalQuyDoi(
                                                  budgetProvider.spent),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Text(
                                          "Total spent",
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 115, 114, 114),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 20),
                                  ],
                                ),
                                const SizedBox(height: 22),
                                // Nút Create Budget
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // Xử lý khi nhấn nút "Create Budget"
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const HomePageAddBudget(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "Create Budget",
                                        style:
                                            TextStyle(color: Color(0xff074799)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // List Budget Items
                    Expanded(
                      child: ListView.builder(
                        itemCount: budgetProvider.budgetItems.length,
                        itemBuilder: (context, index) {
                          var budgetItem = budgetProvider.budgetItems[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 5),
                            child: InkWell(
                              onLongPress: () {
                                showOptionsDialog(context, budgetItem, () {
                                  // Xử lý hành động khi long press
                                  setState(() {
                                    budgetProvider.budgetItems.removeAt(index);
                                  });
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(40),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(15),
                                  title: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/${budgetItem['icon']}.png',
                                        scale: 15,
                                      ),
                                      const SizedBox(width: 20),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(budgetItem['category']),
                                          Text(
                                            "Amount: ${CustomMoney().formatCurrencyTotalNoSymbol(budgetItem['amount'])}",
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    children: [
                                      const Text(
                                        "Remaining amount: ",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        CustomMoney()
                                            .formatCurrencyTotalNoSymbol(
                                                budgetItem['remainingAmount']),
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
