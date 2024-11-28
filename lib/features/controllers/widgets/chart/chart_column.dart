import 'package:flutter/material.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_money.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChartColumn extends StatefulWidget {
  const ChartColumn({super.key});

  @override
  State<ChartColumn> createState() => _ChartColumnState();
}

class _ChartColumnState extends State<ChartColumn> {
  List<ChartColumnData> chartData = [];
  double totalExpenseThisWeek = 0; // Tổng tiền đã chi tuần này
  double totalExpenseLastWeek = 0; // Tổng tiền đã chi tuần trước
  bool showInfoBox = false; // Kiểm soát hiển thị hộp thoại
  String infoBoxText = ''; // Nội dung hộp thoại
  String infoAmount = '';

  DateTime startOfThisWeek = DateTime.now();
  DateTime endOfThisWeek = DateTime.now();
  DateTime startOfLastWeek = DateTime.now();
  DateTime endOfLastWeek = DateTime.now();

  Future<void> fetchData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    DateTime now = DateTime.now();
    startOfThisWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday
    endOfThisWeek = startOfThisWeek.add(const Duration(days: 6)); // Sunday
    startOfLastWeek =
        startOfThisWeek.subtract(const Duration(days: 7)); // Last Monday
    endOfLastWeek =
        startOfThisWeek.subtract(const Duration(days: 1)); // Last Sunday

    QuerySnapshot expenseSnapshot = await firestore
        .collection('transactions')
        .doc('groups_thu_chi')
        .collection('KhoanChi')
        .get();

    for (var doc in expenseSnapshot.docs) {
      double amount = doc['amount'].toDouble();
      Timestamp date = doc['date'];
      DateTime dateTime = date.toDate();

      // Tổng tiền chi cho tuần này
      if (dateTime.isAfter(startOfThisWeek.subtract(const Duration(days: 1))) &&
          dateTime.isBefore(endOfThisWeek.add(const Duration(days: 1)))) {
        totalExpenseThisWeek += amount.abs();
      }
      // Tổng tiền chi cho tuần trước
      else if (dateTime
              .isAfter(startOfLastWeek.subtract(const Duration(days: 1))) &&
          dateTime.isBefore(endOfLastWeek.add(const Duration(days: 1)))) {
        totalExpenseLastWeek += amount.abs();
      }
    }

    List<ChartColumnData> tempData = [
      ChartColumnData('Tuần trước', totalExpenseLastWeek, null),
      ChartColumnData('Tuần này', totalExpenseThisWeek, null),
    ];

    setState(() {
      chartData = tempData;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    // Định dạng ngày theo kiểu "18 thg 11 - 24 thg 11"
    String formattedMonth =
        DateFormat('MM').format(startOfThisWeek); // Cùng tháng cho cả tuần
    String formattedStartLastWeek = DateFormat('d').format(startOfLastWeek);
    String formattedEndLastWeek = DateFormat('d').format(endOfLastWeek);

  

    return GestureDetector(
      onLongPress: () {
        setState(() {
          showInfoBox = true;

          // Kiểm tra cột "Tuần trước"
          if (chartData[0].x == 'Tuần trước') {
            // Hiển thị ngày tháng của tuần trước
            infoAmount = CustomMoney().formatCurrency(totalExpenseLastWeek);
            infoBoxText =
                '$formattedStartLastWeek thg $formattedMonth - $formattedEndLastWeek thg $formattedMonth';
          }
        });
      },
      onLongPressUp: () {
        setState(() {
          showInfoBox = false;
        });
      },
      child: Stack(
        children: [
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 5.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: screenHeight * 0.28,
                        child: SfCartesianChart(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          primaryXAxis: const CategoryAxis(),
                          primaryYAxis: NumericAxis(
                            isVisible: false,
                            minimum: 0,
                            maximum: chartData.isNotEmpty
                                ? chartData
                                        .map((e) => e.y ?? 0)
                                        .reduce((a, b) => a > b ? a : b) *
                                    1.2
                                : 100,
                          ),
                          plotAreaBorderWidth: 0,
                          plotAreaBorderColor: Colors.black,
                          series: <CartesianSeries>[
                            ColumnSeries<ChartColumnData, String>(
                              borderWidth: 0, // Tắt viền của cột
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              dataSource: chartData,
                              width: 0.4,
                              pointColorMapper: (ChartColumnData data, _) =>
                                  data.x == 'Tuần trước'
                                      ? const Color.fromARGB(255, 242, 136, 136)
                                      : Colors.red,
                              xValueMapper: (ChartColumnData data, _) => data.x,
                              yValueMapper: (ChartColumnData data, _) => data.y,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 27,
                            height: 13,
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Tổng chi",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (showInfoBox)
            Positioned(
              top: 30,
              left: 15,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      infoAmount,
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      infoBoxText,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ChartColumnData {
  final String x;
  final double? y;
  final double? y1;

  ChartColumnData(this.x, this.y, this.y1);
}
