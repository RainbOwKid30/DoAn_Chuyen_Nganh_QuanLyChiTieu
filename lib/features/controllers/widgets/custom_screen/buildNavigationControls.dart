// build_navigation_controls.dart
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BuildNavigationControls extends StatelessWidget {
  final int mainPageIndex;
  final PageController mainPageController;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  const BuildNavigationControls({
    super.key,
    required this.mainPageIndex,
    required this.mainPageController,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.green,
          onPressed: onPreviousPage,
        ),
        Column(
          children: [
            Text(
              mainPageIndex == 0 ? "Trending Report" : "Spending Report",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            SmoothPageIndicator(
              controller: mainPageController,
              count: 2,
              effect: const ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Colors.green,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          color: Colors.green,
          onPressed: onNextPage,
        ),
      ],
    );
  }
}
