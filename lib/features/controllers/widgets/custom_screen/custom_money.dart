// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:intl/intl.dart';

class CustomMoney {
  String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(amount).replaceAll('.', ',');
  }

  String formatCurrencyTotalNoSymbol(double amount) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: "",
      decimalDigits: 0,
    ).format(amount).replaceAll('.', ',');
  }

  String formatCurrencyTotalQuyDoi(double amount) {
    // Kiểm tra nếu số âm, lưu dấu âm lại
    bool isNegative = amount < 0;
    double absAmount = amount.abs(); // Lấy giá trị tuyệt đối của số

    String formattedAmount;

    if (absAmount >= 1000000000) {
      // Tỷ (Billion)
      formattedAmount = '${(absAmount / 1000000000).toStringAsFixed(1)}B';
    } else if (absAmount >= 1000000) {
      // Triệu (Million)
      formattedAmount = '${(absAmount / 1000000).toStringAsFixed(1)}M';
    } else if (absAmount >= 1000) {
      // Hàng nghìn (Thousand) với định dạng K
      formattedAmount =
          '${(absAmount / 1000).toStringAsFixed(0)}K'; // Làm tròn về số nguyên
    } else {
      // Số nhỏ hơn nghìn (Chưa đến 1K)
      formattedAmount = absAmount.toStringAsFixed(0);
    }

    // Nếu số ban đầu là âm, thêm dấu âm vào kết quả
    return isNegative ? '-$formattedAmount' : formattedAmount;
  }
}
