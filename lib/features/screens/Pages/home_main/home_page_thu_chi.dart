// import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quan_ly_chi_tieu/chart/Custom_Screen/chartContainer.dart';
import 'package:quan_ly_chi_tieu/chart/lineChart.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_main/home_page_transaction.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/buildNavigationControls.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_main_scaffold.dart';

class HomePageThuChi extends StatefulWidget {
  const HomePageThuChi({super.key, this.onTap});
  final Widget? onTap;

  @override
  State<HomePageThuChi> createState() => _HomePageThuChiState();
}

class _HomePageThuChiState extends State<HomePageThuChi> {
  // Dữ liệu mẫu cho chi tiêu
  // Dữ liệu mẫu cho chi tiêu
  final List<Map<String, dynamic>> expenseData = [
    {'category': 'Ăn uống', 'amount': 200000, 'date': '01/11/2024'},
    {'category': 'Đi lại', 'amount': 100000, 'date': '02/11/2024'},
    {'category': 'Giải trí', 'amount': 150000, 'date': '03/11/2024'},
    {'category': 'Mua sắm', 'amount': 300000, 'date': '04/11/2024'},
  ];

  // Dữ liệu mẫu cho thu nhập
  final List<Map<String, dynamic>> incomeData = [
    {'source': 'Lương', 'amount': 1000000, 'date': '01/11/2024'},
    {'source': 'Thưởng', 'amount': 900000, 'date': '02/11/2024'},
  ];
  // Tính tổng chi
  int get totalExpenses {
    return expenseData.fold<int>(0, (sum, item) {
      return sum + (item['amount'] as int); // Đảm bảo 'amount' là kiểu int
    });
  }

// Tính tổng thu
  int get totalIncome {
    return incomeData.fold<int>(0, (sum, item) {
      return sum + (item['amount'] as int); // Đảm bảo 'amount' là kiểu int
    });
  }

// Tính tổng thu - chi
  int get totalBalance {
    return totalIncome - totalExpenses; // Lãi hoặc lỗ
  }

  bool _isSecurePassword = true;
  // Vị trí của PageView chính
  int _mainPageIndex = 0;
  // Vị trí của PageView con
  int _subPageIndex = 0;
  final PageController _mainPageController = PageController();
  final PageController _subPageController = PageController();

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
                              text: "$totalBalance",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(
                              text: "đ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
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
                  "Tổng số dư",
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
                  height: 130,
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
                              "Ví của tôi",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const HomePageTransaction(),
                                    ),
                                  );
                                },
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: const Text(
                                    "Xem tất cả",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
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
                                const SizedBox(width: 20),
                                const Text(
                                  "Tiền mặt",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const HomePageTransaction(),
                                    ),
                                  );
                                },
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "$totalBalance",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const TextSpan(
                                          text: "đ",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
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
                  "Báo cáo tháng này",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF626262),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Bạn đã bấm vào báo cáo chi tiết!')),
                      );
                    },
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: const Text(
                        "Báo cáo chi tiết",
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: screenWidth - 40,
                  height: screenHeight - 450, // Chiều cao cho box chứa PageView
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Expanded(
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
                                              "Tổng Chi",
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Color(0xff000000),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              "$totalExpenses",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Color(0xFFFE4646),
                                                fontWeight: FontWeight.w500,
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
                                              "Tổng Thu",
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Color(0xff000000),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              "$totalIncome",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Color(0xFF288BEE),
                                                fontWeight: FontWeight.w500,
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
                                  // Trang 1: PageView con để hiển thị chi tiết chi và thu
                                  Expanded(
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
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 20.0),
                                              child: ChartContainer(
                                                chart: SizedBox(
                                                  // Chiều rộng đầy đủ
                                                  width: double.infinity,
                                                  height: 200,
                                                  child: HomeLineChart(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Trang 1.2: Chi tiết Tổng Thu
                                        Column(
                                          children: [
                                            Text(
                                              "Chi tiết Thu nhập",
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
                              // Trang 2: Biểu đồ chi (Ví dụ trang 2)
                              const Center(child: Text("Trang 2: Biểu đồ chi")),
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
