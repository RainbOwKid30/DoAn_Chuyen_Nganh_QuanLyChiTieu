import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_transaction_scaffol.dart';
import 'package:intl/intl.dart';
import 'package:quan_ly_chi_tieu/features/providers/Transaction_Provider.dart'; // Thêm thư viện intl để xử lý ngày tháng

class HomePageTransaction extends StatefulWidget {
  const HomePageTransaction({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageTransactionState createState() => _HomePageTransactionState();
}

class _HomePageTransactionState extends State<HomePageTransaction>
    with TickerProviderStateMixin {
  String selectedFilter = 'Tháng'; // Giá trị mặc định
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
    if (selectedFilter == 'Ngày') {
      tabs.addAll(List.generate(
        DateTime(now.year, now.month + 1, 0).day, // Số ngày trong tháng
        (index) {
          DateTime date = DateTime(now.year, now.month, index + 1);
          return Tab(child: Text(dateFormat.format(date)));
        },
      ));
    } else if (selectedFilter == 'Tháng') {
      tabs.addAll(List.generate(
        12, // Tổng số tháng trong năm
        (index) {
          String monthYear =
              DateFormat('MM/yyyy').format(DateTime(now.year, index + 1));
          return Tab(child: Text('Tháng $monthYear'));
        },
      ));
    } else if (selectedFilter == 'Năm') {
      tabs.addAll(List.generate(
        6, // Hiển thị các năm gần đây (có thể thay đổi số lượng nếu cần)
        (index) {
          int year = now.year - (5 - index); // Hiển thị các năm gần đây
          return Tab(child: Text('Năm $year'));
        },
      ));
    }

    tabs.add(const Tab(child: Icon(FontAwesomeIcons.angleRight)));

    // Cập nhật lại TabController với số lượng tab mới
    _tabController = TabController(length: tabs.length, vsync: this);

    // Nếu là "Tháng", nhảy đến tháng hiện tại
    if (selectedFilter == 'Tháng') {
      int currentMonth = now.month; // Tháng hiện tại (bắt đầu từ 0)
      _tabController.animateTo(currentMonth);
    }
    // Nếu là "Ngày", nhảy đến ngày hiện tại
    else if (selectedFilter == 'Ngày') {
      int currentDay = now.day;
      _tabController.animateTo(currentDay);
    } else if (selectedFilter == 'Năm') {
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
          const PopupMenuItem<String>(value: 'Ngày', child: Text('Ngày')),
          const PopupMenuItem<String>(value: 'Tháng', child: Text('Tháng')),
          const PopupMenuItem<String>(value: 'Năm', child: Text('Năm')),
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

  @override
  Widget build(BuildContext context) {
    var transactionProvider = Provider.of<TransactionProvider>(context);
    return CustomTransactionScaffol(
      appBar: AppBar(
        toolbarHeight: 100.0,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 50),
                    child: Text(
                      "Số dư",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  //số tiền
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "${transactionProvider.totalBalance} ",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const TextSpan(
                                text: "đ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
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
                    // Lấy năm tương ứng với tab (có thể tính năm cho mỗi tab)
                    DateTime tabYear = getTabYearForIndex(index);
                    // Kiểm tra điều kiện lọc dựa trên lựa chọn (Tháng, Ngày, Năm)
                    if (selectedFilter == 'Tháng') {
                      var selectedMonth = DateTime(now.year, index, 1);

                      filteredIncomeData = incomeData.where((item) {
                        return item['date'].month == selectedMonth.month &&
                            item['date'].year == selectedMonth.year;
                      }).toList();

                      filteredExpenseData = expenseData.where((item) {
                        return item['date'].month == selectedMonth.month &&
                            item['date'].year == selectedMonth.year;
                      }).toList();
                    } else if (selectedFilter == 'Ngày') {
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
                    } else if (selectedFilter == 'Năm') {
                      filteredIncomeData = incomeData.where((item) {
                        return item['date'].year == tabYear.year;
                      }).toList();

                      filteredExpenseData = expenseData.where((item) {
                        return item['date'].year == tabYear.year;
                      }).toList();
                    }

                    return buildMonthTabContent(filteredIncomeData,
                        filteredExpenseData, tabDate, tabYear, selectedMonth);
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Hàm lấy ngày cho mỗi tab
  DateTime getTabDateForIndex(int index) {
    // Trả về ngày tương ứng với tab dựa vào chỉ số index
    if (selectedFilter == 'Ngày') {
      // Giả sử bạn muốn lấy ngày đầu của tháng đó hoặc bất kỳ logic nào khác cho ngày
      return DateTime(
          now.year, now.month, index); // Tháng và ngày tương ứng với tab
    }
    // Nếu không phải lọc theo ngày, trả về giá trị mặc định
    return DateTime(now.year, now.month, 1);
  }
  // Hàm lấy năm cho mỗi tab
  DateTime getTabYearForIndex(int index) {
    // Trả về năm tương ứng với tab dựa vào chỉ số index
    if (selectedFilter == 'Năm') {
      // Giả sử bạn muốn lấy năm hiện tại cộng với chỉ số tab (hoặc có thể thay đổi logic năm)
      return DateTime(now.year, index - 5, 1); // Trả về năm cho tab
    }
    // Nếu không phải lọc theo năm, trả về giá trị mặc định (ví dụ năm hiện tại)
    return DateTime(now.year, 1, 1);
  }

  Widget buildMonthTabContent(
      List<Map<String, dynamic>> incomeData,
      List<Map<String, dynamic>> expenseData,
      DateTime month,
      DateTime year,
      DateTime day) {
    if (incomeData.isEmpty && expenseData.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/empty-box.png",
            scale: 1.5,
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Chạm + để thêm",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 114, 113, 113),
              fontSize: 25,
            ),
          ),
          const SizedBox(
            height: 100,
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: incomeData.length + expenseData.length,
      itemBuilder: (context, index) {
        var data = index < incomeData.length
            ? incomeData[index]
            : expenseData[index - incomeData.length];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                data['group'],
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                'Ngày: ${DateFormat('dd/MM/yyyy').format(data['date'])}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: Text(
                '${data['amount']} ₫',
                style: const TextStyle(
                  color: Colors.black, // Áp dụng màu đã xác định cho số tiền
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
