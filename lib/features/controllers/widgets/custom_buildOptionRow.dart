import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomBuildoptionrow extends StatelessWidget {
  const CustomBuildoptionrow({
    super.key,
    required this.icon,
    required this.text,
    required this.page,
    required this.context1,
    this.onTap, // Thêm tham số onTap
  });
  final Widget icon;
  final String text;
  final Widget page;
  final BuildContext context1;
  final VoidCallback? onTap; // Tham số onTap để truyền hàm vào

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ??
          () {
            // Nếu onTap có giá trị thì dùng, nếu không sẽ dùng mặc định
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
      child: Ink(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  softWrap: true, // Cho phép xuống dòng
                  overflow:
                      TextOverflow.visible, // Hiển thị toàn bộ mà không cắt
                  maxLines: null, // Không giới hạn số dòng
                ),
              ),
              const SizedBox(width: 10), // Thêm khoảng cách trước icon
              const Icon(FontAwesomeIcons.angleRight),
            ],
          ),
        ),
      ),
    );
  }
}
