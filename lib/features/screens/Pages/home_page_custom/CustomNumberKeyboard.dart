import 'package:flutter/material.dart';

class CustomNumberKeyboard extends StatelessWidget {
  final TextEditingController controller;
  final Color textColor;

  const CustomNumberKeyboard({
    super.key,
    required this.controller,
    this.textColor = Colors.black,
  });

  void _onNumberPress(String number) {
    controller.text += number;
  }

  void _onDeletePress() {
    if (controller.text.isNotEmpty) {
      controller.text =
          controller.text.substring(0, controller.text.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      padding: const EdgeInsets.all(20),
      children: [
        ...List.generate(9, (index) {
          return ElevatedButton(
            onPressed: () => _onNumberPress('${index + 1}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(color: textColor, fontSize: 24),
            ),
          );
        }),
        ElevatedButton(
          onPressed: _onDeletePress,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[200],
          ),
          child: Icon(Icons.backspace, color: textColor),
        ),
        ElevatedButton(
          onPressed: () => _onNumberPress('0'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
          ),
          child: Text(
            '0',
            style: TextStyle(color: textColor, fontSize: 24),
          ),
        ),
        ElevatedButton(
          onPressed: () {}, // Bỏ trống hoặc xử lý nút khác (nếu có)
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
          ),
          child: const SizedBox.shrink(),
        ),
      ],
    );
  }
}
