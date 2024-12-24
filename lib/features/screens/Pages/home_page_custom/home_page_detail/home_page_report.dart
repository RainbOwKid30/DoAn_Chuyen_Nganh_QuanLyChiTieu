import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/chart/circularChart.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/chart/circularChart_2.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_screen/custom_money.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_screen/custom_transaction_scaffol.dart';
import 'package:intl/intl.dart';
import 'package:quan_ly_chi_tieu/features/controllers/providers/Transaction_Provider.dart';

class HomePageReport extends StatefulWidget {
  const HomePageReport({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageReportState createState() => _HomePageReportState();
}

class _HomePageReportState extends State<HomePageReport>
    with TickerProviderStateMixin {
  String selectedFilter = 'Month'; // Giá trị mặc định
  // Lưu thông tin ngày/tháng/năm cần lọc
  DateTime selectedDate = DateTime.now();
  DateTime selectedDay = DateTime.now(); // Ngày người dùng chọn
  DateTime selectedMonth = DateTime.now(); // Tháng mặc định
  DateTime selectedYear = DateTime.now(); // Năm mặc định
  late List<Tab> tabs = [];
  late List<Widget> tabsContent = [];
  DateTime now = DateTime.now();
  late TabController _tabController;
  List<List<Widget>> tabContents = []; // Nội dung riêng cho từng tab

  @override
  void initState() {
    super.initState();
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (userId.isNotEmpty) {
      // Tải dữ liệu nếu có userId
      Provider.of<TransactionProvider>(context, listen: false).loadData(userId);
    }
    // Tạo TabController dựa trên số lượng tabs
    _tabController = TabController(length: tabs.length, vsync: this);
    _updateTabs(); // Cập nhật tabs khi khởi tạo
    // Khởi tạo nội dung riêng cho từng tab
    tabContents = List.generate(tabs.length, (index) => []);
    _onTabChange();
    setState(() {}); // Cập nhật giao diện
  }

  // Hàm xử lý khi chọn mục trong menu
  void _onFilterSelected(String value) {
    setState(() {
      selectedFilter = value; // Cập nhật giá trị filter khi người dùng chọn
      _updateTabs(); // Cập nhật lại tabs khi thay đổi lựa chọn
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // Đảm bảo dispose controller khi không cần thiết
    super.dispose();
  }

  void _updateTabs() {
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    tabs = [const Tab(child: Icon(FontAwesomeIcons.angleLeft))];

    // Cập nhật tab theo lựa chọn ngày, tháng hoặc năm
    if (selectedFilter == 'Day') {
      tabs.addAll(List.generate(
        DateTime(now.year, now.month + 1, 0).day, // Số ngày trong tháng
        (index) {
          DateTime date = DateTime(now.year, now.month, index + 1);
          String tabLabel;

          if (date.day == now.day) {
            tabLabel = 'Today'; // Hiển thị "Today" nếu là ngày hiện tại
          } else if (date.day == now.subtract(const Duration(days: 1)).day) {
            tabLabel = 'Yesterday'; // Hiển thị "Yesterday" nếu là ngày hôm qua
          } else {
            tabLabel =
                dateFormat.format(date); // Ngày khác thì hiển thị ngày thực
          }
          return Tab(child: Text(tabLabel));
        },
      ));
    } else if (selectedFilter == 'Month') {
      tabs.addAll(List.generate(
        12, // Tổng số tháng trong năm
        (index) {
          String monthYear =
              DateFormat('MM/yyyy').format(DateTime(now.year, index + 1));
          String tabLabel;

          if (now.month == index + 1) {
            tabLabel =
                'This month'; // Hiển thị "This month" nếu là tháng hiện tại
          } else if (now.month == index + 2 ||
              (now.month == 1 && index + 1 == 12)) {
            tabLabel = 'Last month'; // Hiển thị "Last month" nếu là tháng trước
          } else {
            tabLabel =
                'Month $monthYear'; // Tháng khác thì hiển thị "Month MM/YYYY"
          }
          return Tab(child: Text(tabLabel));
        },
      ));
    } else if (selectedFilter == 'Year') {
      tabs.addAll(List.generate(
        6, // Hiển thị các năm gần đây (có thể thay đổi số lượng nếu cần)
        (index) {
          int year = now.year - (5 - index); // Hiển thị các năm gần đây
          String tabLabel;

          if (year == now.year) {
            tabLabel = 'This year'; // Hiển thị "This year" nếu là năm hiện tại
          } else if (year == now.year - 1) {
            tabLabel = 'Last year'; // Hiển thị "Last year" nếu là năm trước
          } else {
            tabLabel = 'Year $year'; // Năm khác thì hiển thị "Year YYYY"
          }
          return Tab(child: Text(tabLabel));
        },
      ));
    }

    tabs.add(const Tab(child: Icon(FontAwesomeIcons.angleRight)));

    // Cập nhật lại TabController với số lượng tab mới
    _tabController = TabController(length: tabs.length, vsync: this);

    // Nếu là "Tháng", nhảy đến tháng hiện tại
    if (selectedFilter == 'Month') {
      int currentMonth = now.month; // Tháng hiện tại (bắt đầu từ 0)
      _tabController.animateTo(currentMonth);
    }
    // Nếu là "Ngày", nhảy đến ngày hiện tại
    else if (selectedFilter == 'Day') {
      int currentDay = now.day;
      _tabController.animateTo(currentDay); // Lưu ý: danh sách tab bắt đầu từ 0
    } else if (selectedFilter == 'Year') {
      int currentYear = now.year;
      // Tính vị trí của năm hiện tại trong các tab (5 năm gần nhất)
      int yearIndex = currentYear - (now.year - 5);
      _tabController.animateTo(yearIndex + 1); // Cuộn đến tab của năm hiện tại
    }
  }

  // Hàm xử lý sự kiện khi nhấn vào icon menu
  void _onIconButtonPressed(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double positionDx = screenSize.width - 50;
    const double positionDy = 0.0;

    showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(positionDx, positionDy, 0.0, 0.0),
        items: [
          const PopupMenuItem<String>(value: 'Day', child: Text('Day')),
          const PopupMenuItem<String>(value: 'Month', child: Text('Month')),
          const PopupMenuItem<String>(value: 'Year', child: Text('Year')),
        ]).then((selectedValue) {
      if (selectedValue != null) {
        _onFilterSelected(selectedValue); // Cập nhật lọc khi chọn một mục
      }
    });
  }

  // Hàm chuyển sang năm mới
  void _goToNextYear() {
    setState(() {
      now = DateTime(now.year + 1, now.month); // Tăng năm lên 1
      _updateTabs(); // Cập nhật lại tabs cho năm mới
    });
  }

  // Hàm chuyển sang năm trước
  void _goToPreviousYear() {
    setState(() {
      now = DateTime(now.year - 1, now.month); // Giảm năm xuống 1
      _updateTabs(); // Cập nhật lại tabs cho năm trước
    });
  }

  // Hàm xử lý sự kiện khi nhấn vào tab
  void _onTabTapped(int index) {
    // Kiểm tra nếu là mũi tên trái hoặc phải thì chỉ thay đổi năm
    if (index == 0) {
      _goToPreviousYear();
    }
    if (index == tabs.length - 1) {
      _goToNextYear();
    }
  }

  // Hàm khi tab thay đổi
  void _onTabChange() {
    DateTime selectedTabDate = getTabDateForIndex(_tabController.index);
    setState(() {
      selectedDate = selectedTabDate; // Cập nhật ngày/tháng/năm đã chọn
    });
  }

  @override
  Widget build(BuildContext context) {
    var transactionProvider = Provider.of<TransactionProvider>(context);
    return CustomTransactionScaffol(
      appBar: AppBar(
        toolbarHeight: 100.0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft,
              color: Colors.black), // Mũi tên back
          onPressed: () {
            Navigator.pop(context); // Quay lại trang trước
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Balance",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 138, 138, 138),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  //số tiền
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: CustomMoney().formatCurrency(
                                  transactionProvider.totalBalance),
                              style: const TextStyle(
                                color: Color.fromARGB(255, 39, 38, 38),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                _onIconButtonPressed(context);
              },
              padding: const EdgeInsets.only(left: 30),
              icon: const Icon(
                FontAwesomeIcons.ellipsisVertical,
                color: Colors.black,
                size: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          onTap: _onTabTapped,
          isScrollable: true,
          tabs: tabs,
          tabAlignment: TabAlignment.start,
          indicatorPadding: EdgeInsets.zero,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(width: 4.0, color: Colors.grey),
          ),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, transactionProvider, child) {
                // Lấy dữ liệu thu nhập và chi tiêu từ provider
                List<Map<String, dynamic>> incomeData =
                    transactionProvider.incomeData;
                List<Map<String, dynamic>> expenseData =
                    transactionProvider.expenseData;

                return TabBarView(
                  controller: _tabController,
                  children: List.generate(tabs.length, (index) {
                    // Khởi tạo hai danh sách để lưu trữ dữ liệu đã lọc
                    List<Map<String, dynamic>> filteredIncomeData = [];
                    List<Map<String, dynamic>> filteredExpenseData = [];

                    // Lấy ngày tương ứng với tab
                    DateTime tabDate = getTabDateForIndex(index);
                    // Kiểm tra điều kiện lọc dựa trên lựa chọn (Tháng, Ngày, Năm)
                    if (selectedFilter == 'Month') {
                      filteredIncomeData = incomeData.where((item) {
                        return item['date'].month == tabDate.month &&
                            item['date'].year == tabDate.year;
                      }).toList();

                      filteredExpenseData = expenseData.where((item) {
                        return item['date'].month == tabDate.month &&
                            item['date'].year == tabDate.year;
                      }).toList();
                    } else if (selectedFilter == 'Day') {
                      filteredIncomeData = incomeData.where((item) {
                        return item['date'].day == tabDate.day &&
                            item['date'].month == tabDate.month &&
                            item['date'].year == tabDate.year;
                      }).toList();

                      filteredExpenseData = expenseData.where((item) {
                        return item['date'].day == tabDate.day &&
                            item['date'].month == tabDate.month &&
                            item['date'].year == tabDate.year;
                      }).toList();
                    } else if (selectedFilter == 'Year') {
                      filteredIncomeData = incomeData.where((item) {
                        return item['date'].year == tabDate.year;
                      }).toList();

                      filteredExpenseData = expenseData.where((item) {
                        return item['date'].year == tabDate.year;
                      }).toList();
                    }

                    return buildMonthTabContent(filteredIncomeData,
                        filteredExpenseData, tabDate, selectedFilter);
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  DateTime getTabDateForIndex(int index) {
    if (selectedFilter == 'Day') {
      // Trả về ngày tương ứng với tab dựa vào chỉ số index
      return DateTime(now.year, now.month, index); // Ngày trong tháng hiện tại
    } else if (selectedFilter == 'Month') {
      // Trả về tháng tương ứng với tab dựa vào chỉ số index
      return DateTime(now.year, index, 1); // Tháng trong năm hiện tại
    } else if (selectedFilter == 'Year') {
      // Trả về năm tương ứng với tab dựa vào chỉ số index
      return DateTime(now.year, index - 5, 1); // Chỉnh lại dựa trên số năm
    }
    // Nếu không phải lọc theo ngày, tháng, hay năm, trả về giá trị mặc định
    return DateTime(now.year, now.month, 1); // Trả về ngày đầu tháng hiện tại
  }

  Widget buildMonthTabContent(
      List<Map<String, dynamic>> incomeData,
      List<Map<String, dynamic>> expenseData,
      DateTime date,
      String selectedFill) {
    double totalIncome =
        incomeData.fold(0, (sum, item) => sum + item['amount']);
    double totalExpense =
        expenseData.fold(0, (sum, item) => sum + item['amount']);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Container Expense
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // container Expense
                  Row(
                    children: [
                      Expanded(
                        child: incomeData.isEmpty && expenseData.isEmpty
                            ? buildEmptyExpenseContainer()
                            : buildExpenseContainer(
                                totalExpense, selectedFill, date),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Container Income
                  Row(
                    children: [
                      Expanded(
                        child: incomeData.isEmpty && expenseData.isEmpty
                            ? buildEmptyIncomeContainer()
                            : buildIncomeContainer(
                                totalIncome, selectedFill, date),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyExpenseContainer() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Row(
              children: [
                Text(
                  "Expense",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                Text(
                  '0',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildExpenseContainer(
      double totalExpense, String selectedFill, DateTime date) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Row(
              children: [
                const Text(
                  "Expense",
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
                            content: Text('Bạn đã bấm vào xem tất cả')),
                      );
                    },
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: const Text(
                        "See Details",
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
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Row(
              children: [
                Text(
                  CustomMoney().formatCurrencyTotalNoSymbol(totalExpense),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Circularchart(
                    selectedFilter: selectedFill,
                    selectedDate: date,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyIncomeContainer() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Row(
              children: [
                Text(
                  "Income",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                Text(
                  '0',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIncomeContainer(
      double totalIncome, String selectedFill, DateTime date) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Row(
              children: [
                const Text(
                  "Income",
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
                            content: Text('Bạn đã bấm vào xem tất cả')),
                      );
                    },
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: const Text(
                        "See Details",
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
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Row(
              children: [
                Text(
                  CustomMoney().formatCurrencyTotalNoSymbol(totalIncome),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Circularchart2(
                    selectedFilter: selectedFill,
                    selectedDate: date,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
