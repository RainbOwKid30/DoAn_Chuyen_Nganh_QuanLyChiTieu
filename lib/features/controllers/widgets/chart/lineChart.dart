import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quan_ly_chi_tieu/features/controllers/colors/app_colors.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_screen/custom_format_money.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_screen/custom_money.dart';

class HomeLineChart extends StatefulWidget {
  const HomeLineChart({super.key});

  @override
  State<HomeLineChart> createState() => _LineChartSample2State();
}

DateTime now = DateTime.now();
DateTime firstDay = DateTime(now.year, now.month, 1);
DateTime lastDay = DateTime(now.year, now.month + 1, 0);
double amount = 0.0;
double totalExpense1 = 0.0;
List<FlSpot> spots = [];

class _LineChartSample2State extends State<HomeLineChart> {
  List<Color> gradientColors = [
    AppColors.contentColorOrange,
    AppColors.contentColorRed,
  ];

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
    fetchTotalExpenses();
  }

  void fetchTotalExpenses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Lấy dữ liệu trong collection "transactions"
    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .doc('groups_thu_chi')
        .collection('KhoanChi') // Nếu 'KhoanChi' là một collection con
        .where('userId', isEqualTo: user.uid)
        .where('date', isGreaterThanOrEqualTo: firstDay) // Lọc từ đầu tháng
        .where('date', isLessThanOrEqualTo: lastDay) // Lọc đến cuối tháng
        .get();

    double totalExpense = 0.0;

    // Duyệt qua các giao dịch trong tháng để tính tổng chi
    for (var doc in snapshot.docs) {
      final amount = (doc['amount'] as num).toDouble();
      totalExpense += amount;
    }

    setState(() {
      totalExpense1 = totalExpense; // Cập nhật tổng chi tiêu
    });
  }

  void fetchDataFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Truy vấn vào collection "groups_thu_chi_KhoanChi" trong "transactions"
    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .doc('groups_thu_chi')
        .collection('KhoanChi') // Nếu 'KhoanChi' là một collection con
        .where('userId', isEqualTo: user.uid)
        .get();

    // Map dữ liệu từ Firestore
    Map<int, double> transactionData = {};
    for (var doc in snapshot.docs) {
      final date = (doc['date'] as Timestamp).toDate(); // Lấy ngày
      if (date.month == now.month && date.year == now.year) {
        final day = date.day;
        final amount = (doc['amount'] as num).toDouble(); // Lấy số tiền
        transactionData[day] = (transactionData[day] ?? 0) + amount;
      }
    }

    // Gán giá trị cho tất cả các ngày trong tháng từ 1 đến ngày hiện tại
    List<FlSpot> tempSpots = [];
    int currentDay = now.day; // Ngày hiện tại

    for (int day = 1; day <= currentDay; day++) {
      tempSpots.add(FlSpot(
          day.toDouble(),
          // Giá trị mặc định là 0 nếu không có giao dịch
          const CustomFormatMoney().convertAmount(
            transactionData[day] ?? 0.0,
          )));
    }

    setState(() {
      spots = tempSpots;
    });
  }

  // Lấy ngày đầu và cuối tháng hiện tại
  String getFirstDayOfMonth() {
    return DateFormat('dd/MM').format(firstDay);
  }

  String getLastDayOfMonth() {
    return DateFormat('dd/MM').format(lastDay);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.3,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 20,
              left: 24,
              top: 30, // Tăng khoảng cách trên để tăng chiều cao
              bottom: 20, // Tăng khoảng cách dưới
            ),
            child: LineChart(
              mainData(),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 16,
    );
    Widget text;
    // Chỉnh sửa trục X với các ngày trong tháng
    if (value == firstDay.day) {
      text = Text(getFirstDayOfMonth(), style: style); // 1/11
    } else if (value == lastDay.day) {
      text = Text(getLastDayOfMonth(), style: style); // 31/11
    } else {
      text =
          const Text('', style: style); // Nếu không phải ngày đầu và cuối tháng
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 12,
    );

    String text;
    double total = totalExpense1 / 3;

    // Quy đổi giá trị dựa trên các mức ngưỡng
    if (totalExpense1 < 100000) {
      // Quy đổi cho 0 - 99,999
      switch (value.toInt()) {
        case 0:
          text = '0';
          break;
        case 1:
          text = CustomMoney().formatCurrencyTotalQuyDoi(total);
          break;
        case 2:
          text = CustomMoney().formatCurrencyTotalQuyDoi(total * 2);
          break;
        case 3:
          text = CustomMoney().formatCurrencyTotalQuyDoi(total * 3);
          break;
        default:
          return Container();
      }
    } else if (totalExpense1 >= 100000 && totalExpense1 < 1000000) {
      // Quy đổi cho 100K - 999K
      switch (value.toInt()) {
        case 0:
          text = '0';
          break;
        case 1:
          text = CustomMoney().formatCurrencyTotalQuyDoi(total);
          break;
        case 2:
          text = CustomMoney().formatCurrencyTotalQuyDoi(total * 2);
          break;
        case 3:
          text = CustomMoney().formatCurrencyTotalQuyDoi(total * 3);
          break;
        default:
          return Container();
      }
    } else if (totalExpense1 >= 1000000 && totalExpense1 < 10000000) {
      // Quy đổi cho 1M - 9,999,999
      switch (value.toInt()) {
        case 1:
          text = CustomMoney().formatCurrencyTotalQuyDoi(total);
          break;
        case 2:
          text = CustomMoney().formatCurrencyTotalQuyDoi(total * 2);
          break;
        case 3:
          text = CustomMoney().formatCurrencyTotalQuyDoi(total * 3);
          break;
        default:
          return Container();
      }
    } else if (totalExpense1 >= 10000000 && totalExpense1 < 100000000) {
      // Quy đổi cho 10M - 99M
      switch (value.toInt()) {
        case 0:
          text = '0';
          break;
        case 1:
          text = CustomMoney().formatCurrencyTotalQuyDoi(total);
          break;
        case 2:
          text = CustomMoney().formatCurrencyTotalQuyDoi(total * 2);
          break;
        case 3:
          text = CustomMoney().formatCurrencyTotalQuyDoi(total * 3);
          break;
        default:
          return Container();
      }
    } else if (totalExpense1 >= 100000000 && totalExpense1 < 1000000000) {
      // Quy đổi cho 100M - 999M
      switch (value.toInt()) {
        case 0:
          text = '0';
          break;
        case 1:
          text = CustomMoney().formatCurrencyTotalQuyDoi(total);
          break;
        case 2:
          text = CustomMoney().formatCurrencyTotalQuyDoi(total * 2);
          break;
        case 3:
          text = CustomMoney().formatCurrencyTotalQuyDoi(total * 3);
          break;
        default:
          return Container();
      }
    } else {
      text = 'N/A'; // Giá trị mặc định nếu không khớp
    }

    // Hiển thị title bên phải
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.right,
      ),
    );
  }

  // Hàm chính cho LineChartData
  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          if (value == 0) {
            return const FlLine(color: Colors.black, strokeWidth: 1);
          } else if (value == 1 || value == 2 || value == 3) {
            return const FlLine(
                color: Colors.grey, strokeWidth: 1, dashArray: [3, 3]);
          }
          return const FlLine(color: Colors.transparent);
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
              color: AppColors.mainGridLineColor, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: rightTitleWidgets,
            reservedSize: 50,
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          top: BorderSide(color: Colors.transparent, width: 0),
          right: BorderSide(color: Colors.transparent, width: 0),
          left: BorderSide(color: Colors.transparent, width: 0),
          bottom: BorderSide(color: Colors.black, width: 1),
        ),
      ),
      minX: firstDay.day.toDouble(),
      maxX: lastDay.day.toDouble(),
      minY: 0,
      maxY: 4,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.contentColorRed,
          barWidth: 2,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.red.withOpacity(0.4),
                Colors.white.withOpacity(1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          dotData: FlDotData(
            show: true,
            checkToShowDot: (spot, barData) {
              return spot.x == barData.spots.last.x;
            },
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 3,
                strokeColor: Colors.red,
              );
            },
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipRoundedRadius: 8,
          // Đảm bảo tooltip nằm trong ranh giới theo chiều ngang
          fitInsideHorizontally: true,
          // Đảm bảo tooltip nằm trong ranh giới theo chiều dọc
          fitInsideVertically: true,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((touchedSpot) {
              // Chuyển đổi ngày tháng từ số ngày thành định dạng ngày tháng
              String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime(
                DateTime.now().year,
                DateTime.now().month,
                touchedSpot.x.toInt(),
              ));

              double formattedAmount =
                  const CustomFormatMoney().convertBackToAmount(touchedSpot.y);

              // Hiển thị tooltip với ngày tháng và giá trị
              return LineTooltipItem(
                '$formattedDate\n${CustomMoney().formatCurrency(formattedAmount)}',
                const TextStyle(color: Colors.white),
              );
            }).toList();
          },
          tooltipMargin: 8, // Giữ khoảng cách với đường biểu đồ
          tooltipPadding: const EdgeInsets.all(8), // Padding của tooltip
        ),
        touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
          // Sự kiện chạm có thể không cần thiết, nhưng giữ lại nếu muốn xử lý thêm
        },
        handleBuiltInTouches: true,
      ),
    );
  }
}
