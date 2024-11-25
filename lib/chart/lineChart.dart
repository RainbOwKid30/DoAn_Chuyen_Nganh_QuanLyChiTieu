import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeLineChart extends StatefulWidget {
  const HomeLineChart({super.key});

  @override
  State<HomeLineChart> createState() => _HomeLineChartState();
}

class _HomeLineChartState extends State<HomeLineChart> {
  double amount1 = 0.0; // Khởi tạo amount1

  // Cập nhật giá trị amount1 và rebuild widget khi dữ liệu thay đổi
  void updateAmount(double newAmount) {
    setState(() {
      amount1 = newAmount; // Cập nhật giá trị mới
    });
  }

  @override
  Widget build(BuildContext context) {
    // Bạn có thể thay đổi amount1 trực tiếp tại đây, ví dụ:
    updateAmount(120000); // Đây là một ví dụ cho việc cập nhật amount1

    return LineChart(
      LineChartData(
        gridData: const FlGridData(
            show: true, drawVerticalLine: false, drawHorizontalLine: true),
        titlesData: titlesData,
        borderData: borderData,
        lineBarsData: lineBarsData,
        minX: 1,
        minY: 0,
        maxX: 30,
        maxY: 4, // Thay đổi maxY tự động dựa trên amount1
      ),
    );
  }

  double donvi(double amount) {
    if (amount < 100000) {
      return (amount / 100000) * 4;
    } else if (amount >= 100000 && amount < 500000) {
      return (amount / 500000) * 4;
    } else if (amount >= 500000 && amount < 1000000) {
      return (amount / 1000000) * 4;
    }
    return 4; // Giá trị mặc định là 4 nếu không thỏa điều kiện trên
  }

  List<LineChartBarData> get lineBarsData => [
        lineChartBarsData1,
      ];

  FlTitlesData get titlesData => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: AxisTitles(
          sideTitles: rightTitles(),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  // Cập nhật lại phần rightTitles để thay đổi theo amount1
  SideTitles rightTitles() => SideTitles(
        showTitles: true,
        reservedSize: 50,
        interval: 1,
        getTitlesWidget: (value, meta) {
          // Dùng donvi(amount1) để xác định giá trị trục Y
          double maxAmount = donvi(amount1);

          if (amount1 < 100000 && maxAmount <= 4.0) {
            // Trường hợp amount1 nhỏ hơn 100k
            if (value == 0) {
              return const Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                  "0",
                  style: TextStyle(fontSize: 20),
                ),
              );
            }
            if (value == 1) {
              return const Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text("30 k"),
              );
            }
            if (value == 2) {
              return const Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text("60 k"),
              );
            }
            if (value == 3) {
              return const Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text("90 k"),
              );
            }
          } else if (amount1 >= 100000 &&
              amount1 < 500000 &&
              maxAmount <= 4.0) {
            // Trường hợp amount1 từ 100k đến 500k
            if (value == 0) {
              return const Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text("0", style: TextStyle(fontSize: 20)),
              );
            }
            if (value == 1) {
              return const Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text("300 k"),
              );
            }
            if (value == 2) {
              return const Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text("600 k"),
              );
            }
            if (value == 3) {
              return const Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text("900 k"),
              );
            }
          }
          return Container(); // Không hiển thị các giá trị khác
        },
      );

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        interval: 1, // Khoảng cách giữa các nhãn là 1 ngày
        reservedSize: 50,
        getTitlesWidget: (value, meta) {
          DateTime currentDate = DateTime.now();
          int currentMonth = currentDate.month; // Lấy tháng hiện tại
          int currentYear = currentDate.year; // Lấy năm hiện tại
          // Chỉ hiển thị nhãn đầu tháng và cuối tháng
          if (value == 1) {
            return Padding(
              padding: const EdgeInsets.only(top: 5.0, left: 30.0),
              child: Text(
                DateFormat('d/M')
                    .format(DateTime(currentYear, currentMonth, 1)),
              ),
            );
          } else if (value == 30) {
            DateTime lastDay = DateTime(currentYear, currentMonth + 1, 0);
            return Padding(
              padding: const EdgeInsets.only(top: 5.0, right: 30.0),
              child: Text(DateFormat('d/M').format(lastDay)),
            );
          }
          return const Text(''); // Bỏ qua các ngày khác
        },
      );

  FlGridData get gridData => FlGridData(
        show: true,
        drawVerticalLine: false,
        drawHorizontalLine: true,
        horizontalInterval: 1, // Đặt khoảng cách giữa các dấu chấm là 1
        getDrawingHorizontalLine: (value) {
          if (value == 1 || value == 2 || value == 3) {
            // Sử dụng FlLine để vẽ các dấu chấm thay vì đường liên tục
            return const FlLine(
              color: Colors.grey,
              strokeWidth: 1,
              dashArray: [5, 5], // Tạo dấu chấm bằng cách thiết lập mảng dash
            );
          }
          return const FlLine(
              color: Colors.transparent); // Không hiển thị các đường khác
        },
      );

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 3,
          ),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      );

  LineChartBarData get lineChartBarsData1 => LineChartBarData(
        isCurved: true,
        color: const Color(0xFFFE4646),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFE4646).withOpacity(0.4), // Đỏ mờ
              Colors.white, // Màu trắng
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        spots: [
          FlSpot(1, donvi(amount1)),
          const FlSpot(3, 1),
          const FlSpot(6, 1),
          const FlSpot(8, 3),
          const FlSpot(11, 2),
          const FlSpot(16, 3),
          const FlSpot(18, 3.4)
        ],
      );
}
