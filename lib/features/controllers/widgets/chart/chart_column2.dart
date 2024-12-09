import 'package:flutter/material.dart';
import 'package:quan_ly_chi_tieu/features/controllers/chart2_controller.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_screen/custom_money.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartColumn2 extends StatefulWidget {
  const ChartColumn2({super.key});

  @override
  State<ChartColumn2> createState() => _ChartColumnState();
}

class _ChartColumnState extends State<ChartColumn2> {
  List<ChartColumnData> chartData = [];
  double totalExpenseThisMonth = 0; // Tổng tiền đã chi tháng này
  double totalExpenseLastMonth = 0; // Tổng tiền đã chi tháng trước
  bool showInfoBox = false; // Kiểm soát hiển thị hộp thoại
  String infoBoxText = ''; // Nội dung hộp thoại
  String infoAmount = '';

  DateTime startOfThisMonth = DateTime.now();
  DateTime endOfThisMonth = DateTime.now();
  DateTime startOfLastMonth = DateTime.now();
  DateTime endOfLastMonth = DateTime.now();

  String formattedStartLastMonth = '';
  String formattedEndLastMonth = '';

  final Chart2Controller chartController = Chart2Controller();
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    Map<String, dynamic> expenseData = await chartController.fetchExpenseData();
    setState(() {
      totalExpenseThisMonth = expenseData['thisMonth'] ?? 0;
      totalExpenseLastMonth = expenseData['lastMonth'] ?? 0;
      formattedStartLastMonth = expenseData['formattedStartLastMonth'] ?? '';
      formattedEndLastMonth = expenseData['formattedEndLastMonth'] ?? '';

      chartData = [
        ChartColumnData('Tháng trước', totalExpenseLastMonth, null),
        ChartColumnData('Tháng này', totalExpenseThisMonth, null),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onLongPress: () {
        setState(() {
          showInfoBox = true;

          // Kiểm tra cột "Tháng trước"
          if (chartData[0].x == 'Tháng trước') {
            // Hiển thị ngày tháng của tháng trước
            infoAmount = CustomMoney().formatCurrency(totalExpenseLastMonth);
            infoBoxText = '$formattedStartLastMonth - $formattedEndLastMonth';
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
                              borderWidth: 0,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              dataSource: chartData,
                              width: 0.4,
                              pointColorMapper: (ChartColumnData data, _) =>
                                  data.x == 'Tháng trước'
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
  final double? z;

  ChartColumnData(this.x, this.y, this.z);
}
