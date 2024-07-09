import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qlmoney/screen/bottom_navigation_bar.dart';
import 'package:qlmoney/screen/login_or_register_page.dart';

class LoginMainPage extends StatelessWidget {
  const LoginMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const BottomNavigationPage();
            } else {
              return const LoginOrRegisterPage();
            }
          }),
    );
  }
}
