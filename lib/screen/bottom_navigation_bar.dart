import 'package:flutter/material.dart';
import 'package:qlmoney/screen/add_page.dart';
import 'package:qlmoney/screen/home.dart';
import 'package:qlmoney/screen/remind_page.dart';
import 'package:qlmoney/screen/thongke_page.dart';

import 'account_page.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({Key? key}) : super(key: key);

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int myCurrentIndex = 0;

  List pages =  [
    HomePage(),
    ThongKePage(),
    AddThuChiPage(),
    RemindPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[myCurrentIndex],
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.orange,
        ),
        child: IconButton(
          onPressed: () {
            setState(() {
              myCurrentIndex = 2;
            });
          },
          icon: Icon(Icons.add),
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(255, 104, 184, 248),
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home_outlined),
              onPressed: () {
                setState(() {
                  myCurrentIndex = 0;
                });
              },
              color: myCurrentIndex == 0 ? Colors.red : Colors.black,
            ),
            Container(
              // color: Colors.blue,
              child: IconButton(
                icon: Icon(Icons.bar_chart_sharp),
                onPressed: () {
                  setState(() {
                    myCurrentIndex = 1;
                  });
                },
                color: myCurrentIndex == 1 ? Colors.red : Colors.black,
              ),
            ),
            IconButton(
              icon: Icon(Icons.calendar_month),
              onPressed: () {
                setState(() {
                  myCurrentIndex = 3;
                });
              },
              color: myCurrentIndex == 3 ? Colors.red : Colors.black,
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                setState(() {
                  myCurrentIndex = 4;
                });
              },
              color: myCurrentIndex == 4 ? Colors.red : Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
