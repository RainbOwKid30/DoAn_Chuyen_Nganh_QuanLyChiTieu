import 'package:flutter/cupertino.dart';

class CustomFormatMoney extends StatelessWidget {
  const CustomFormatMoney({super.key});

  // Hàm quy đổi amount thành giá trị từ 1 - 4 theo từng ngưỡng
  double convertAmount(double amount) {
    if (amount <= 100000) {
      // Quy đổi cho 0 - 99,999
      return (amount / 100000) * 1; // Giá trị từ 0 -> 1
    } else if (amount <= 1000000) {
      // Quy đổi cho 100k - 999k
      return ((amount - 100000) / (1000000 - 100000)) * 1 +
          1; // Giá trị từ 1 -> 2
    } else if (amount <= 10000000) {
      // Quy đổi cho 1m - 9,999,999
      return ((amount - 1000000) / (10000000 - 1000000)) * 1 +
          2; // Giá trị từ 2 -> 3
    } else if (amount <= 100000000) {
      // Quy đổi cho 10m - 99m
      return ((amount - 10000000) / (100000000 - 10000000)) * 1 +
          3; // Giá trị từ 3 -> 4
    }
    return 4; // Nếu lớn hơn 99m, trả về 4
  }

  // Hàm quy đổi ngược lại từ giá trị đã được convert về số tiền gốc
  double convertBackToAmount(double convertedValue) {
    if (convertedValue <= 1) {
      // Quy đổi cho 0 - 99,999
      return (convertedValue / 1) * 100000;
    } else if (convertedValue <= 2) {
      // Quy đổi cho 100k - 999k
      return ((convertedValue - 1) / 1) * (1000000 - 100000) + 100000;
    } else if (convertedValue <= 3) {
      // Quy đổi cho 1m - 9,999,999
      return ((convertedValue - 2) / 1) * (10000000 - 1000000) + 1000000;
    } else if (convertedValue <= 4) {
      // Quy đổi cho 10m - 99m
      return ((convertedValue - 3) / 1) * (100000000 - 10000000) + 10000000;
    }
    return 0; // Nếu giá trị không hợp lệ
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
