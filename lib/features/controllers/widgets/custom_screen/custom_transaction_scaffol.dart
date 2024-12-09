import 'package:flutter/material.dart';

class CustomTransactionScaffol extends StatelessWidget {
  const CustomTransactionScaffol({
    super.key,
    this.child,
    this.appBar,
    this.tabs,
    this.tabsContent,
    this.body,
  });

  final Widget? child;
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final List<Tab>? tabs;
  final List<Widget>? tabsContent;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      // Đảm bảo số lượng tabs luôn khớp với tabsContent
      length: tabs?.length ?? 0,
      child: Scaffold(
        appBar: appBar,
        backgroundColor: const Color(0xFFD0CBCB),
        body: tabs != null &&
                tabsContent != null &&
                tabs!.length == tabsContent!.length
            ? Column(
                children: [
                  // Hiển thị TabBar nếu có tabs
                  if (tabs != null)
                    TabBar(
                      tabs: tabs!,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      // Xóa khoảng đệm indicator
                      indicatorPadding: EdgeInsets.zero,
                      indicatorColor: Colors.grey,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                    ),
                  Expanded(
                    child: TabBarView(
                      children: tabsContent!,
                    ),
                  ),
                ],
              )
            : body ?? // Hiển thị body nếu không dùng tabs
                SafeArea(
                  child:
                      child ?? Container(), // Hiển thị child nếu không có body
                ),
      ),
    );
  }
}
