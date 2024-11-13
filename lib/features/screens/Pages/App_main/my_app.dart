import 'package:flutter/material.dart';
import 'package:quan_ly_chi_tieu/bottom_navigation_custom/bottom_custom.dart';
import 'package:quan_ly_chi_tieu/theme/theme_custom.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeCustom.themeLight,
      debugShowCheckedModeBanner: false,
      home: const BottomNavigationCustom(),
    );
  }
}
