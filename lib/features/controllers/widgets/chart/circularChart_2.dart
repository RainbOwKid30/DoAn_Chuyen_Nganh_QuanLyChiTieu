import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Circularchart2 extends StatefulWidget {
  final String selectedFilter; // Bộ lọc: Day, Month, Year
  final DateTime selectedDate; // Ngày của tab hiện tại
  const Circularchart2(
      {super.key, required this.selectedFilter, required this.selectedDate});

  @override
  State<Circularchart2> createState() => _Circularchart2State();
}

class _Circularchart2State extends State<Circularchart2> {
  List chartData = []; // Dữ liệu biểu đồ
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _fetchFirestoreData(); // Lấy dữ liệu Firestore khi khởi tạo
  }

  // Hàm tạo màu ngẫu nhiên
  Color _generateRandomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1, // Alpha (độ trong suốt): 1 = không trong suốt
    );
  }

  // Hàm lấy dữ liệu từ Firestore
  Future<void> _fetchFirestoreData() async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('transactions')
          .doc('groups_thu_chi')
          .collection('KhoanThu')
          .where('userId', isEqualTo: userId);

      // Thêm bộ lọc dựa trên selectedFilter
      if (widget.selectedFilter == 'Day') {
        query = query.where('date',
            isEqualTo: Timestamp.fromDate(widget.selectedDate));
      } else if (widget.selectedFilter == 'Month') {
        DateTime startOfMonth =
            DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
        DateTime endOfMonth = DateTime(
            widget.selectedDate.year, widget.selectedDate.month + 1, 0);
        query = query
            .where('date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth));
      } else if (widget.selectedFilter == 'Year') {
        DateTime startOfYear = DateTime(widget.selectedDate.year, 1, 1);
        DateTime endOfYear = DateTime(widget.selectedDate.year, 12, 31);
        query = query
            .where('date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear))
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfYear));
      }

      QuerySnapshot snapshot = await query.get();

      // Chuyển đổi dữ liệu từ Firestore
      List fetchedData = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return [
          data['amount'], // Số tiền
          data['group'], // Tên nhóm
          _generateRandomColor(), // Màu ngẫu nhiên
          data['icon'], // Tên icon
        ];
      }).toList();

      // Tính tổng số tiền
      double totalAmount = fetchedData.fold(
        0,
        (previousValue, element) => previousValue + element[0],
      );

      // Chuyển số tiền thành phần trăm
      List percentageData = fetchedData.map((item) {
        double percentage = (item[0] / totalAmount) * 100;
        return [
          percentage, // Phần trăm
          item[1], // Tên nhóm
          item[2], // Màu
          item[3], // Tên icon
        ];
      }).toList();

      // Cập nhật chartData và giao diện
      setState(() {
        chartData = percentageData;
      });
    } catch (e) {
      print('Lỗi khi lấy dữ liệu Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: chartData.isEmpty
          // Hiển thị khi đang load
          ? Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Stack(
                children: [
                  SfCircularChart(
                    margin: const EdgeInsets.all(0),
                    series: [
                      DoughnutSeries(
                        dataSource: chartData,
                        yValueMapper: (data, _) => data[0], // Phần trăm
                        xValueMapper: (data, _) => data[1], // Tên nhóm
                        radius: '70%',
                        innerRadius: '50%',
                        explode: true,
                        // Màu ngẫu nhiên
                        pointColorMapper: (data, _) => data[2],
                        dataLabelMapper: (data, _) =>
                            '${data[0].toStringAsFixed(1)}%',
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          textStyle:
                              TextStyle(fontSize: 13, color: Colors.black),
                          labelPosition: ChartDataLabelPosition.outside,
                        ),
                      ),
                    ],
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      orientation: LegendItemOrientation.horizontal,
                      textStyle: const TextStyle(fontSize: 13),
                      iconHeight: 30,
                      iconWidth: 30,
                      // Hiển thị icon từ Firestore
                      legendItemBuilder: (String name, dynamic series,
                          dynamic point, int index) {
                        return Row(
                          children: [
                            Image.asset(
                              'assets/images/${chartData[index][3]}.png', // Tên icon từ Firestore
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              chartData[index][1], // Tên nhóm
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  // Hiển thị thêm widget icon nếu cần
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Stack(
                children: [
                  SfCircularChart(
                    margin: const EdgeInsets.all(0),
                    series: [
                      DoughnutSeries(
                        dataSource: chartData,
                        yValueMapper: (data, _) => data[0], // Phần trăm
                        xValueMapper: (data, _) => data[1], // Tên nhóm
                        radius: '70%',
                        innerRadius: '50%',
                        explode: true,
                        // Màu ngẫu nhiên
                        pointColorMapper: (data, _) => data[2],
                        dataLabelMapper: (data, _) =>
                            '${data[0].toStringAsFixed(1)}%',
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          textStyle:
                              TextStyle(fontSize: 13, color: Colors.black),
                          labelPosition: ChartDataLabelPosition.outside,
                        ),
                      ),
                    ],
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      orientation: LegendItemOrientation.horizontal,
                      textStyle: const TextStyle(fontSize: 13),
                      iconHeight: 30,
                      iconWidth: 30,
                      // Hiển thị icon từ Firestore
                      legendItemBuilder: (String name, dynamic series,
                          dynamic point, int index) {
                        return Row(
                          children: [
                            Image.asset(
                              'assets/images/${chartData[index][3]}.png', // Tên icon từ Firestore
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              chartData[index][1], // Tên nhóm
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  // Hiển thị thêm widget icon nếu cần
                ],
              ),
            ),
    );
  }
}
