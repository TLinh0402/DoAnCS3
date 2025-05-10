import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:qlmoney/data/list_price.dart';
import 'package:qlmoney/screen/all_khoanthuchi_page.dart';
import 'package:qlmoney/chatbot/chatbot_page.dart';
import '../data/money.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.lightBlue[400],
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text("ChatBot"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatBotPage()),
          );
        },
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            FutureBuilder<List<int>>(
              future: Future.wait([
                _firebaseService.getPriceIncomeInDay(),
                _firebaseService.getPriceExpenseInDay(),
                _firebaseService.totalIncome(),
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: SpinKitWave(
                        color: Colors.blue,
                        size: 50.0,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                } else {
                  if (snapshot.hasData && snapshot.data!.length == 3) {
                    int totalIncome = snapshot.data![0];
                    int totalExpense = snapshot.data![1];
                    int total = snapshot.data![2];
                    return SliverToBoxAdapter(
                      child: _headerSection(
                        context,
                        user.email!,
                        totalIncome,
                        totalExpense,
                        total,
                      ),
                    );
                  } else {
                    return const SliverFillRemaining(
                      child: Center(
                        child: Text('Unexpected data format'),
                      ),
                    );
                  }
                }
              },
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 19,
                        color: Colors.blueGrey,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AllKhoanThuChi()),
                        );
                      },
                      child: const Text(
                        'See all',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FutureBuilder<List<Money>>(
              future: _firebaseService.getMoneyData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: SpinKitWave(
                        color: Colors.blue,
                        size: 50.0,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                } else {
                  List<Money>? moneyList = snapshot.data;
                  if (moneyList == null || moneyList.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: Text("No transactions found."),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.asset(
                              'assets/image/${moneyList[index].icon}.png',
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            moneyList[index].name ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                            ),
                          ),
                          subtitle: Text(
                            moneyList[index].time ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.blueGrey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          trailing: Text(
                            ((moneyList[index].type ?? 'Income') == 'Income'
                                ? "+\$ "
                                : "-\$ ") +
                                (moneyList[index].price ?? '0'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: (moneyList[index].type ?? 'Income') ==
                                  'Income'
                                  ? Colors.green
                                  : Colors.pink,
                            ),
                          ),
                        );
                      },
                      childCount: moneyList.length > 5 ? 5 : moneyList.length,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerSection(BuildContext context, String emailUser, int income, int expense, int total) {
    int remaining = total - expense;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Hello 👋",
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
              ),
              Text(
                emailUser,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Total Balance",
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "\$ $remaining",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summaryBox("Income", income, Colors.green),
                        _summaryBox("Expense", expense, Colors.pink),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _summaryBox(String title, int amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "\$ $amount",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
