import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:qlmoney/widgets/add_expense_form.dart';
import 'package:qlmoney/widgets/add_income_form.dart';

import 'bottom_navigation_bar.dart';



class AddThuChiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: TabBar(
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 4.0, color: Colors.blueAccent),
                insets: EdgeInsets.symmetric(horizontal: 16.0),
              ),
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.blueGrey,
              labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              tabs: [
                Tab(
                  text: 'Income',
                  icon: Icon(Ionicons.arrow_up_circle_outline),
                ),
                Tab(
                  text: 'Expense',
                  icon: Icon(Ionicons.arrow_down_circle_outline),
                ),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            AddIncomeForm(),
            AddExpenseForm(),
          ],
        ),
      ),
    );
  }
}









