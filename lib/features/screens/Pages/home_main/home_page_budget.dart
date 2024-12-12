import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_chi_tieu/features/controllers/providers/BudgetProvider.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_screen/custom_money.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_page_custom/home_page_add_budget.dart';

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
      duration: const Duration(seconds: 2), // Thời gian hiệu ứng
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

    Provider.of<BudgetProvider>(context, listen: false).fetchBudgetData();
  }

  // Hàm bắt đầu animation với giá trị progress mới
  void _startAnimation() {
    // Kiểm tra nếu totalBudget == 0
    if (totalBudget == 0) {
      // Nếu totalBudget bằng 0, không có chi tiêu, đặt progress là 0
      _progressAnimation = Tween<double>(begin: 0, end: 0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
    } else {
      // Tính toán phần trăm chi tiêu
      double progress = spent / totalBudget; // Tính toán phần trăm chi tiêu

      _progressAnimation = Tween<double>(begin: 0, end: progress).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
    }

    _animationController.forward(from: 0); // Bắt đầu hiệu ứng
  }

  Future<void> _fetchBudgetData() async {
    try {
      DateTime now = DateTime.now();
      int currentYear = now.year;
      int currentMonth = now.month;

      DateTime firstDayOfMonth = DateTime(currentYear, currentMonth, 1);
      DateTime lastDayOfMonth = DateTime(currentYear, currentMonth + 1, 0);

      QuerySnapshot budgetSnapshot = await FirebaseFirestore.instance
          .collection('budgets')
          .where('startDate', isGreaterThanOrEqualTo: firstDayOfMonth)
          .where('startDate', isLessThanOrEqualTo: lastDayOfMonth)
          .get();

      double totalBudget = 0;
      List<Map<String, dynamic>> items = [];

      // Lấy tất cả categoryId từ ngân sách
      List<String> categoryIds = [];

      for (var doc in budgetSnapshot.docs) {
        totalBudget += doc['amount'];
        String categoryId = doc['categoryId'];
        categoryIds.add(categoryId); // Lưu categoryId để lấy chi tiêu sau

        // Truy vấn category thông qua categoryId
        await _fetchCategoryInfo(categoryId).then((categoryInfo) {
          items.add({
            'id': doc.id,
            'category': categoryInfo['name'],
            'icon': categoryInfo['icon'],
            'amount': doc['amount'],
            // Số tiền còn lại = số tiền ngân sách ban đầu
            'remainingAmount': doc['amount'],
            'categoryId': categoryId, // Lưu categoryId vào item
          });
        });
      }

      double totalSpent = 0;

      // Nếu có categoryId trong budgets, tính chi tiêu theo categoryId
      if (categoryIds.isNotEmpty && totalBudget > 0) {
        // Khai báo lại transactionSnapshot ở đây
        QuerySnapshot transactionSnapshot = await FirebaseFirestore.instance
            .collection('transactions')
            .doc('groups_thu_chi')
            .collection('KhoanChi')
            .where('date', isGreaterThanOrEqualTo: firstDayOfMonth)
            .where('date', isLessThanOrEqualTo: lastDayOfMonth)
            .where('categoryId', whereIn: categoryIds) // Lọc theo categoryId
            .get();

        for (var doc in transactionSnapshot.docs) {
          totalSpent += doc['amount'];
        }

        // Cập nhật số tiền còn lại cho mỗi item
        for (var i = 0; i < items.length; i++) {
          String categoryId = items[i]['categoryId'];
          double spentForCategory = 0;

          // Tính chi tiêu cho từng categoryId
          for (var doc in transactionSnapshot.docs) {
            if (doc['categoryId'] == categoryId) {
              spentForCategory += doc['amount'];
            }
          }

          // Cập nhật số tiền còn lại cho mỗi item
          items[i]['remainingAmount'] = items[i]['amount'] - spentForCategory;
        }
      }

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              this.totalBudget = totalBudget;
              spent = totalSpent;
              sotienconlai = totalBudget - totalSpent;
              budgetItems = items;
            });

            _startAnimation();
          }
        });
      }
    } catch (e) {
      print("Error fetching budget data: $e");
    }
  }

  // Lấy thông tin category từ Firestore qua categoryId
  Future<Map<String, dynamic>> _fetchCategoryInfo(String categoryId) async {
    try {
      DocumentSnapshot categoryDoc = await FirebaseFirestore.instance
          .collection('categories')
          .doc('group_category') // Lấy danh mục group_category
          .collection('KhoanChi') // Lấy KhoanChi bên trong group_category
          .doc(categoryId) // Truy vấn theo categoryId
          .get();

      if (categoryDoc.exists) {
        return {
          'name': categoryDoc['name'],
          'icon': categoryDoc['icon'],
        };
      } else {
        return {
          'name': 'Không có tên',
          'icon': Icons.help_outline, // Nếu không tìm thấy, gán icon mặc định
        };
      }
    } catch (e) {
      print("Error fetching category info: $e");
      return {
        'name': 'Không có tên',
        'icon': Icons.help_outline,
      };
    }
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
    const currentMonthLabel = "Tháng này";

    return DefaultTabController(
      length: 1, // Số lượng tab
      child: Scaffold(
        backgroundColor: const Color(0xFFD0CBCB),
        appBar: AppBar(
          title: const Center(
            child: Text(
              "Ngân sách Tổng",
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
                                      "Mức độ chi tiêu (${(_progressAnimation.value * 100).toStringAsFixed(1)}%)",
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
                                      "Số tiền còn lại bạn có thể chi",
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
                                          "Tổng ngân sách",
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
                                          "Tổng đã chi",
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
                    Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: budgetProvider.budgetItems.length,
                          itemBuilder: (context, index) {
                            var budgetItem = budgetProvider.budgetItems[index];
                            return Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
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
                                          "Số tiền: ${CustomMoney().formatCurrencyTotalNoSymbol(budgetItem['amount'])}",
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
                                trailing: Text(
                                  CustomMoney().formatCurrencyTotalNoSymbol(
                                      budgetItem['remainingAmount']),
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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
