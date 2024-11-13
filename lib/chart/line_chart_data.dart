import 'package:fl_chart/fl_chart.dart';

class LineChartData {
  final spots = [
    const FlSpot(1.68, 2.04),
    const FlSpot(2.68, 2.04),
    const FlSpot(3.68, 31.04),
    const FlSpot(4.68, 4.04),
    const FlSpot(5.68, 5.04),
    const FlSpot(6.68, 6.04),
    const FlSpot(7.68, 4.04),
    const FlSpot(18.68, 1.04),
    const FlSpot(19.68, 3.04),
    const FlSpot(103.68, 5.04),
    const FlSpot(155.68, 3.04),
  ];

  final rightTitle = {
    0: '0',
    20: '2k',
    40: '4k',
    60: '6k',
    80: '8k',
    100: '10k',
  };
  final bottomTitle = {
    0: 'Jan',
    10: 'Feb',
    20: 'Mar',
    30: 'Apr',
    40: 'May',
    50: 'Jun',
    60: 'Jul',
    70: 'Aug',
    80: 'Sep',
    90: 'Oct',
    100: 'Nov',
    110: 'Dec',
  };
}
