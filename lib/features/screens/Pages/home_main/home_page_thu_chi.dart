// import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_chi_tieu/features/controllers/expense_controller.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/chart/chart_column.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/chart/chart_column2.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/chart/lineChart.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_screen/buildNavigationControls.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_screen/custom_money.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_screen/custom_main_scaffold.dart';
import 'package:quan_ly_chi_tieu/features/controllers/providers/Transaction_Provider.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_page_custom/home_page_detail/home_page_report.dart';

class HomePageThuChi extends StatefulWidget {
  const HomePageThuChi({super.key, this.onTap});
  final Widget? onTap;

  @override
  State<HomePageThuChi> createState() => _HomePageThuChiState();
}

class _HomePageThuChiState extends State<HomePageThuChi> {
  List<Map<String, dynamic>> expenseData = [];
  List<Map<String, dynamic>> incomeData = [];
  double totalExpenseThisWeek = 0;
  double totalExpenseThisMonth = 0;
  // Tạo controller
  final ExpenseController _expenseController = ExpenseController();

  @override
  void initState() {
    super.initState();
    // Load dữ liệu từ Firestore
    // _loadData();
    // Lấy userId từ Firebase Authentication
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (userId.isNotEmpty) {
      // Tải dữ liệu nếu có userId
      Provider.of<TransactionProvider>(context, listen: false).loadData(userId);
    }
    fetchData();
  }

  bool _isSecurePassword = true;
  // Vị trí của PageView chính
  int _mainPageIndex = 0;
  // Vị trí của PageView con
  int _subPageIndex = 0;
  final PageController _mainPageController = PageController();
  final PageController _subPageController = PageController();

  // Hàm lấy dữ liệu từ controller
  Future<void> fetchData() async {
    var expenseData = await _expenseController.fetchExpenseData();
    setState(() {
      totalExpenseThisWeek = expenseData['thisWeek'] ?? 0;
      totalExpenseThisMonth = expenseData['thisMonth'] ?? 0;
    });
  }

  void _previousPage() {
    if (_mainPageIndex > 0) {
      _mainPageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    if (_mainPageIndex < 1) {
      _mainPageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Lấy dữ liệu từ TransactionProvider
    var transactionProvider = Provider.of<TransactionProvider>(context);

    return CustomMainScaffold(
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          children: [
            // số tiền và icon chuông
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (!_isSecurePassword)
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: CustomMoney().formatCurrency(
                                  transactionProvider.totalBalance),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const Text(
                        "**********",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(width: 1),
                    IconButton(
                      icon: Icon(
                        _isSecurePassword
                            ? FontAwesomeIcons.eyeSlash
                            : FontAwesomeIcons.eye,
                        size: 20,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSecurePassword = !_isSecurePassword;
                        });
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(FontAwesomeIcons.bell),
                  color: Colors.black,
                  iconSize: 20,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bạn đã bấm vào chuông!')),
                    );
                  },
                ),
              ],
            ),
            const Row(
              children: [
                Text(
                  "Total balance",
                  style: TextStyle(
                    color: Color(0xFF626262),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 30.0),
            ),
            // box ví tiền
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: screenWidth - 40,
                  height: 120,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "My wallet",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Bạn đã bấm vào xem tất cả')),
                                  );
                                },
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: const Text(
                                    "See All",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        thickness: 1,
                        color: Color(0xFFb7b7b7),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/walletmoney.png',
                                  width: 40,
                                  height: 40,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Cash",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: CustomMoney().formatCurrency(
                                            transactionProvider.totalBalance),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.only(top: 25.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "This month's report",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF626262),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePageReport()),
                      );
                    },
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: const Text(
                        "See report",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            //body thu chi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: screenWidth - 40,
                  height: screenHeight - 400,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          child: PageView(
                            controller: _mainPageController,
                            onPageChanged: (index) {
                              setState(() {
                                _mainPageIndex = index;
                              });
                            },
                            children: [
                              // Trang 1: Mục "Tổng Chi" và "Tổng Thu"
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // Mục Tổng Chi
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _subPageIndex = 0;
                                            // Chuyển đến trang chi
                                            _subPageController.jumpToPage(0);
                                          });
                                        },
                                        child: Column(
                                          children: [
                                            const Text(
                                              "Expense",
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Color(0xff000000),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              CustomMoney()
                                                  .formatCurrencyTotalNoSymbol(
                                                      transactionProvider
                                                          .totalExpenses),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Color(0xFFFE4646),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              width: 175,
                                              height: 2,
                                              color: _subPageIndex == 0
                                                  ? const Color(0xFFFE4646)
                                                  : Colors.transparent,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Mục Tổng Thu
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _subPageIndex = 1;
                                            // Chuyển đến trang thu
                                            _subPageController.jumpToPage(1);
                                          });
                                        },
                                        child: Column(
                                          children: [
                                            const Text(
                                              "Income",
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Color(0xff000000),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              CustomMoney()
                                                  .formatCurrencyTotalNoSymbol(
                                                      transactionProvider
                                                          .totalIncome),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Color(0xFF288BEE),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              width: 175,
                                              height: 2,
                                              color: _subPageIndex == 1
                                                  ? const Color(0xFF288BEE)
                                                  : Colors.transparent,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Trang PageView con để hiển thị chi tiết chi và thu
                                  Flexible(
                                    flex: 1,
                                    child: PageView(
                                      controller: _subPageController,
                                      onPageChanged: (index) {
                                        setState(() {
                                          _subPageIndex = index;
                                        });
                                      },
                                      children: const [
                                        // Trang 1.1: Chi tiết Tổng Chi
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            HomeLineChart(),
                                          ],
                                        ),
                                        // Trang 1.2: Chi tiết Tổng Thu
                                        Column(
                                          children: [
                                            Text(
                                              "Detail Income",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Trang 2: Biểu đồ cột theo tuần, tháng
                              Column(
                                children: [
                                  Container(
                                    height: 40,
                                    padding: const EdgeInsets.only(
                                        left: 5.0,
                                        right: 5.0,
                                        top: 4.0,
                                        bottom: 4.0),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 218, 217, 217),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // Mục Tuần
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _subPageIndex = 0;
                                              // Chuyển đến trang chi
                                              _subPageController.jumpToPage(0);
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 165,
                                                height: 30,
                                                padding: const EdgeInsets.only(
                                                    left: 1.0),
                                                decoration: BoxDecoration(
                                                  color: _subPageIndex == 0
                                                      ? const Color(0xFFFFFFFF)
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    "Week",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Color.fromARGB(
                                                          255, 81, 80, 80),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Mục Tháng
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _subPageIndex = 1;
                                              // Chuyển đến trang thu
                                              _subPageController.jumpToPage(1);
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 165,
                                                height: 30,
                                                padding: const EdgeInsets.only(
                                                    left: 1.0),
                                                decoration: BoxDecoration(
                                                  color: _subPageIndex == 1
                                                      ? const Color(0xFFFFFFFF)
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    "Month",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Color.fromARGB(
                                                          255, 81, 80, 80),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Trang PageView con để hiển thị biểu đồ cột
                                  Flexible(
                                    flex: 1,
                                    child: PageView(
                                      controller: _subPageController,
                                      onPageChanged: (index) {
                                        setState(() {
                                          _subPageIndex = index;
                                        });
                                      },
                                      children: [
                                        // Trang 1.1: biểu đồ cột theo tuần
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  CustomMoney().formatCurrency(
                                                      totalExpenseThisWeek),
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Row(
                                              children: [
                                                Text(
                                                  "Total This Week",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Column(
                                              children: [
                                                ChartColumn(),
                                              ],
                                            ),
                                          ],
                                        ),

                                        // Trang 1.2: biểu đồ cột theo tháng
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  CustomMoney().formatCurrency(
                                                      totalExpenseThisMonth),
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Row(
                                              children: [
                                                Text(
                                                  "Total This Month",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Column(
                                              children: [
                                                ChartColumn2(),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      BuildNavigationControls(
                        mainPageIndex: _mainPageIndex,
                        mainPageController: _mainPageController,
                        onPreviousPage: _previousPage,
                        onNextPage: _nextPage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
