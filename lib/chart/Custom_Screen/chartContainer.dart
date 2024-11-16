import 'package:flutter/material.dart';

class ChartContainer extends StatelessWidget {
  final Widget chart;
  const ChartContainer({super.key, required this.chart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: chart,
    );
  }
}
