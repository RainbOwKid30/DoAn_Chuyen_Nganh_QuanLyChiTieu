import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_chi_tieu/features/controllers/providers/BillProvider.dart';
import 'package:quan_ly_chi_tieu/features/controllers/providers/Transaction_Provider.dart';
import 'package:quan_ly_chi_tieu/features/controllers/widgets/custom_screen/custom_money.dart';
import 'package:quan_ly_chi_tieu/features/screens/Pages/home_main/home_page_create_item_bill.dart';

class HomePageBill extends StatefulWidget {
  const HomePageBill({super.key});

  @override
  State<HomePageBill> createState() => _HomePageBillState();
}

class _HomePageBillState extends State<HomePageBill> {
  double totalBudget = 0; // Tổng ngân sách
  double spent = 0; // Số tiền đã chi
  double sotienconlai = 0; // Số tiền còn lại
  bool billProvider = false;

  @override
  void initState() {
    super.initState();
    // Lấy dữ liệu hóa đơn
    final billProvider = Provider.of<Billprovider>(context, listen: false);
    billProvider.fetchBillData().then((_) {
      setState(() {
        totalBudget = billProvider.totalTransaction;
        spent = billProvider.spent;
        sotienconlai = totalBudget - spent; // Tính số tiền còn lại
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var transactionProvider = Provider.of<TransactionProvider>(context);

    // Lắng nghe sự thay đổi của billProvider
    return Consumer<Billprovider>(
      builder: (context, billProvider, child) {
        // Calculate remaining money when bill data changes
        totalBudget = billProvider.totalTransaction;
        spent = billProvider.spent;
        sotienconlai = totalBudget - spent; // Tính số tiền còn lại

        return billProvider.billItem.isNotEmpty
            ? buildItem(billProvider, transactionProvider)
            : buildNoneItem();
      },
    );
  }

  Widget buildNoneItem() {
    return Scaffold(
      backgroundColor: const Color(0xFFD0CBCB),
      appBar: AppBar(
        title: const Text(
          "Bill",
          style: TextStyle(color: Color(0xFF000000)),
        ),
        leading: IconButton(
          color: const Color(0xff000000),
          icon: const Icon(FontAwesomeIcons.angleLeft),
          onPressed: () {
            Navigator.pop(context); // Quay lại trang trước
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/empty-box.png", scale: 2),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "You don't have bill !!!",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Tap the + button to create a new Bill",
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(221, 116, 115, 115),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePageCreateItemBill(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildItem(
      Billprovider billProvider, TransactionProvider transactionProvider) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFD0CBCB),
      appBar: AppBar(
        title: const Text(
          "Bill",
          style: TextStyle(color: Color(0xFF000000)),
        ),
        leading: IconButton(
          color: const Color(0xff000000),
          icon: const Icon(FontAwesomeIcons.angleLeft),
          onPressed: () {
            Navigator.pop(context); // Quay lại trang trước
          },
        ),
      ),
      body: Consumer<Billprovider>(
        builder: (context, billProvider, child) {
          return Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              // container top
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: screenWidth,
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Remaining Bill",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(
                          thickness: 1,
                          color: Color(0xFFb7b7b7),
                        ),
                        //dòng balance
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Text(
                                    "Balance",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(255, 127, 127, 127),
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: CustomMoney()
                                              .formatCurrencyTotalNoSymbol(
                                            transactionProvider.totalBalance,
                                          ),
                                          style: const TextStyle(
                                            color: Color(0xff288BEE),
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        //dòng money period
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Text(
                                    "This PERIOD",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(255, 127, 127, 127),
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: CustomMoney()
                                              .formatCurrencyTotalNoSymbol(
                                                  sotienconlai),
                                          style: const TextStyle(
                                            color: Color(0xffFF0004),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: billProvider.billItem.length,
                  itemBuilder: (context, index) {
                    var billItem = billProvider.billItem[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 0.0),
                      child: Container(
                        padding: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tiêu đề "This PERIOD"
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "This PERIOD",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            const Divider(
                              thickness: 1,
                              color: Color(0xFFb7b7b7),
                            ),
                            const SizedBox(height: 10),
                            // Nội dung của từng mục
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/${billItem['categoryIcon']}.png',
                                  scale: 15,
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      billItem['categoryName'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    //ngày đến hạn 1
                                    Text(
                                      "Next bill is ${billItem['nextBillDate']}",
                                      style: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 128, 128, 128),
                                        fontSize: 13,
                                      ),
                                    ),
                                    // ngày đến hạn 2
                                    Text(
                                      "Due in ${billItem['daysUntilDue']} days",
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    //nút pay
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          // Số tiền hiện có trong tài khoản
                                          double balance =
                                              transactionProvider.totalBalance;
                                          // Số tiền cần thanh toán
                                          double amountToPay =
                                              billItem['amount'];

                                          // Kiểm tra xem balance có đủ để thanh toán hay không
                                          if (balance >= amountToPay) {
                                            // Nếu đủ tiền, thực hiện thanh toán
                                            billProvider
                                                .calculateRemainingAmount();
                                            billProvider.updateBillStatus(
                                                billItem['id']);
                                            billProvider.fetchBillData();
                                            // Sau khi thanh toán xong, có thể xóa item khỏi danh sách và load lại dữ liệu
                                            setState(() {
                                              billProvider.billItem
                                                  .removeAt(index);
                                            });
                                          } else {
                                            // Nếu không đủ tiền, hiển thị thông báo
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title:
                                                      const Text('Thông báo'),
                                                  content: const Text(
                                                      'Bạn không đủ tiền để thanh toán!'),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(); // Đóng thông báo
                                                      },
                                                      child: const Text('OK'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        } catch (e) {
                                          print("Error during payment: $e");
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                      child: Text(
                                        'PAY ${CustomMoney().formatCurrencyTotalNoSymbol(billItem['amount'])}',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePageCreateItemBill(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
