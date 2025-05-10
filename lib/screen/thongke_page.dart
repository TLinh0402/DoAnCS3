import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qlmoney/data/list_price.dart';
import 'package:qlmoney/data/money.dart';

class ThongKePage extends StatefulWidget {
  @override
  _ThongKePageState createState() => _ThongKePageState();
}

class _ThongKePageState extends State<ThongKePage> {
  FirebaseService firebaseService = FirebaseService();
  List<Money> moneyData = [];
  bool isLoading = true;
  Map<String, double> categoryTotal = {};
  double totalIncome = 0;
  double totalExpenses = 0;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    List<Money> data = await firebaseService.thongKe();
    setState(() {
      moneyData = data;
      isLoading = false;
      categoryTotal = calculateCategoryTotal(data);
    });
  }

  Map<String, double> calculateCategoryTotal(List<Money> data) {
    Map<String, double> result = {};
    double income = 0;
    double expenses = 0;
    for (var money in data) {
      String category = money.nameCategory ?? 'Unknown';
      double amount = double.tryParse(money.price ?? '0') ?? 0;
      if (money.type == 'Income') {
        income += amount;
      } else if (money.type == 'Expense') {
        expenses += amount;
      }

      if (category != 'Lương') {
        result[category] = (result[category] ?? 0) + amount;
      }
    }
    totalIncome = income;
    totalExpenses = expenses;
    return result;
  }

  void filterDataByDate() {
    List<Money> filteredData = moneyData.where((money) {
      if (money.time == null) return false;
      final moneyDate = DateFormat('dd/MM/yy').parse(money.time!);
      return (startDate == null || !moneyDate.isBefore(startDate!)) &&
          (endDate == null || !moneyDate.isAfter(endDate!));
    }).toList();

    setState(() {
      categoryTotal = calculateCategoryTotal(filteredData);
    });
  }

  void updateChartData() {
    filterDataByDate();
  }

  List<PieChartSectionData> generatePieChartData() {
    if (categoryTotal.isEmpty) return [];

    double total = categoryTotal.values.fold(0, (a, b) => a + b);
    return categoryTotal.entries
        .where((e) => e.key != 'Lương')
        .map((entry) {
      double percent = (entry.value / total * 100);
      return PieChartSectionData(
        color: Colors.primaries[
        categoryTotal.keys.toList().indexOf(entry.key) % Colors.primaries.length],
        value: entry.value,
        title: '${entry.key}\n${percent.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<PieChartSectionData> generateIncomeExpenseChartData() {
    double remaining = totalIncome - totalExpenses;
    double total = totalIncome == 0 ? 1 : totalIncome;
    return [
      PieChartSectionData(
        color: Colors.red,
        value: totalExpenses,
        title: 'Chi\n${(totalExpenses / total * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: remaining,
        title: 'Dư\n${(remaining / total * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistics"),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Select Time Range',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDateButton("Start", startDate, Colors.orange, true),
                  _buildDateButton("End", endDate, Colors.teal, false),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: updateChartData,
                child: const Text("Thống kê"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),

              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    categoryTotal.clear(); // Xoá danh mục => dùng biểu đồ chi/dư
                  });
                },
                child: const Text("Revenue"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),

              const SizedBox(height: 20),
              AspectRatio(
                aspectRatio: 2,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 3,
                      )
                    ],
                    color: Colors.white,
                  ),
                  child: PieChart(
                    PieChartData(
                      sections: categoryTotal.isNotEmpty
                          ? generatePieChartData()
                          : generateIncomeExpenseChartData(),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Details by Category",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categoryTotal.length,
                itemBuilder: (context, index) {
                  final category = categoryTotal.keys.toList()[index];
                  if (category == 'Lương') return const SizedBox(); // Skip "Lương"
                  final amount = categoryTotal[category]!;
                  final total = categoryTotal.values.fold(0.0, (a, b) => a + b);

                  final percentage = (amount / total * 100).toStringAsFixed(1);
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          category[0],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      title: Text(
                        category,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Tổng: \$${amount.toStringAsFixed(2)}\nChiếm: $percentage%",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateButton(String label, DateTime? date, Color color, bool isStart) {
    return ElevatedButton(
      onPressed: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (selectedDate != null) {
          setState(() {
            if (isStart) {
              startDate = selectedDate;
            } else {
              endDate = selectedDate;
            }
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Text(
        date != null
            ? '$label: ${DateFormat('dd/MM/yyyy').format(date)}'
            : '$label Date',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
