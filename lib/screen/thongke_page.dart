import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qlmoney/data/list_price.dart';
import 'package:qlmoney/data/money.dart';

class ThongKePage extends StatefulWidget {
  @override
  _ThongKePageState createState() => _ThongKePageState();
}

class _ThongKePageState extends State<ThongKePage> {
  String selectedCategory = 'Chi'; // Default category
  FirebaseService firebaseService = FirebaseService();
  List<Money> moneyData = [];
  bool isLoading = true;
  Map<String, double> categoryTotal = {}; // Total amount for each category
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
      categoryTotal = calculateCategoryTotal(
          data); // Calculate total amount for each category
    });
  }

  Map<String, double> calculateCategoryTotal(List<Money> data) {
    Map<String, double> result = {};
    double income = 0;
    double expenses = 0;
    data.forEach((money) {
      String category = money.nameCategory ?? 'Unknown';
      double amount = double.tryParse(money.price ?? '0') ?? 0;
      if (money.type == 'Income') {
        income += amount;
      } else if (money.type == 'Expense') {
        expenses += amount;
      }

      if (category != 'Lương') {
        if (result.containsKey(category)) {
          result[category] = result[category]! + amount;
        } else {
          result[category] = amount;
        }
      }
    });
    totalIncome = income;
    totalExpenses = expenses;
    return result;
  }

  void filterDataByDate() {
    // Filter data based on the selected date range
    List<Money> filteredData = moneyData.where((money) {
      if (money.time == null) {
        return false; // Skip entry if there's no time
      }
      final moneyDate = DateFormat('dd/MM/yy').parse(money.time!);
      return (startDate == null || moneyDate.isAfter(startDate!)) &&
          (endDate == null ||
              moneyDate.isBefore(endDate!.add(Duration(days: 1))));
    }).toList();

    // Recalculate total amount for each category based on filtered data
    setState(() {
      categoryTotal = calculateCategoryTotal(filteredData);
    });
  }

  void updateChartData() {
    filterDataByDate(); // Filter data when pressing "Thống kê"
  }

  List<PieChartSectionData> generatePieChartData() {
    if (categoryTotal.isEmpty) {
      return []; // Return an empty list if categoryTotal has no entries
    }

    double totalExcludingLuong = categoryTotal.values.reduce((a, b) => a + b);
    return categoryTotal.entries
        .where((entry) => entry.key != 'Lương')
        .map((entry) {
      final percentage =
      (entry.value / totalExcludingLuong * 100).toStringAsFixed(1);
      return PieChartSectionData(
        color: Colors.primaries[categoryTotal.keys.toList().indexOf(entry.key) %
            Colors.primaries.length],
        value: entry.value,
        title: '${entry.key}\n$percentage%',
        radius: 50,
        titleStyle: TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  List<PieChartSectionData> generateIncomeExpenseChartData() {
    double remainingMoney = totalIncome - totalExpenses;
    double totalAmount = totalIncome; // Total amount is totalIncome

    double expensesPercentage = (totalExpenses / totalAmount * 100).toDouble();
    double remainingPercentage = (remainingMoney / totalAmount * 100).toDouble();

    return [
      PieChartSectionData(
        color: Colors.red,
        value: expensesPercentage,
        title: 'Chi\n${expensesPercentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.blue,
        value: remainingPercentage,
        title: 'Dư\n${remainingPercentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Statistical",
          style: TextStyle(color: Colors.blue, fontSize: 22),
        ),
        elevation: 5, // Add shadow to the AppBar
        shadowColor: Colors.grey,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 15),
              const Text(
                'TIME:',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (selectedDate != null) {
                        final formattedDate =
                        DateFormat('yyyy-MM-dd').format(selectedDate);
                        setState(() {
                          startDate = DateTime.parse(formattedDate);
                        });
                      }
                    },
                    child: Text(
                      startDate != null
                          ? 'Start: ${DateFormat('dd/MM/yyyy').format(startDate!)}'
                          : 'StartDate',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (selectedDate != null) {
                        final formattedDate =
                        DateFormat('yyyy-MM-dd').format(selectedDate);
                        setState(() {
                          endDate = DateTime.parse(formattedDate);
                        });
                      }
                    },
                    child: Text(
                      endDate != null
                          ? 'End: ${DateFormat('dd/MM/yyyy').format(endDate!)}'
                          : 'EndDate',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  updateChartData();
                },
                child: Text('Statistical', style: TextStyle(fontSize: 16),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                  padding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // Refresh the chart data to show income and expense statistics
                    categoryTotal.clear(); // Clear category data
                  });
                },
                child: Text('Revenue'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),

              SizedBox(height: 10),
              AspectRatio(
                aspectRatio: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // Change shadow position
                        ),
                      ],
                    ),
                    child: PieChart(
                      PieChartData(
                        sections: categoryTotal.isNotEmpty
                            ? generatePieChartData()
                            : generateIncomeExpenseChartData(),
                        borderData: FlBorderData(show: false), // Hide border
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // const Text(
              //   'Chi tiết:',
              //   style: TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.blue,
              //   ),
              //   textAlign: TextAlign.center,
              // ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: categoryTotal.length,
                itemBuilder: (BuildContext context, int index) {
                  final category = categoryTotal.keys.toList()[index];
                  if (category == 'Lương') return SizedBox();
                  final amount = categoryTotal[category]!;
                  final totalExcludingLuong =
                  categoryTotal.values.reduce((a, b) => a + b);
                  final percentage = (amount / totalExcludingLuong * 100)
                      .toStringAsFixed(1);
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: Card(
                      elevation: 5, // Add shadow to each Card
                      shadowColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          category,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Tổng số tiền: $amount\nPhần trăm: $percentage%',
                        ),
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
}
