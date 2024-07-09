import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:qlmoney/screen/bottom_navigation_bar.dart';
import 'package:qlmoney/screen/edit_account_page.dart';
import 'package:qlmoney/screen/screen_started.dart';
import 'package:qlmoney/widgets/forward_button.dart';
import 'package:qlmoney/widgets/setting_item.dart';
import 'package:qlmoney/widgets/setting_switch.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool isDarkMode = false;
  String? _avatarUrl;
  String? _nameUser;
  final DatabaseReference _userRef =
      FirebaseDatabase.instance.reference().child('users').child('account');

  @override
  void initState() {
    super.initState();
    fetchDataFromFirebase();
  }

  // Fetch data from Firebase
  void fetchDataFromFirebase() {
    _userRef.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null && snapshot.value is Map<dynamic, dynamic>) {
        var userData = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _avatarUrl = userData['avatar'];
          _nameUser = userData['name'];
        });
      }
    }).catchError((error) {
      print('Đã xảy ra lỗi khi lấy dữ liệu từ Firebase: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Ionicons.chevron_back_outline),
        ),
        leadingWidth: 80,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Settings",
                      style: TextStyle(
                        color: Colors.blue.shade300,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _avatarUrl != null
                              ? Image.network(
                                  _avatarUrl!,
                                  width: 70,
                                  height: 70,
                                  errorBuilder: (BuildContext context,
                                      Object exception,
                                      StackTrace? stackTrace) {
                                    return Image.asset(
                                      'assets/image/avatar.png',
                                      width: 70,
                                      height: 70,
                                    );
                                  },
                                )
                              : Image.asset(
                                  "assets/image/avatar.png",
                                  width: 70,
                                  height: 70,
                                ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _nameUser != null
                                  ? Text(
                                      _nameUser!,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  : const Text(
                                      "Default Name",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                              const Text(
                                "22IT.B121",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          ForwardButton(
                            ontap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const EditAccountPage()),
                              );

                              if (result != null) {
                                setState(() {
                                  _avatarUrl = result as String;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "Settings",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SettingItem(
                      title: "Language",
                      icon: Ionicons.earth,
                      bgColor: Colors.orange.shade100,
                      iconColor: Colors.orange,
                      value: "English",
                      onTap: () {},
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SettingItem(
                      title: "Notification",
                      icon: Ionicons.notifications,
                      bgColor: Colors.blue.shade100,
                      iconColor: Colors.blue,
                      onTap: () {},
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SettingSwitch(
                      title: "Dark Mode",
                      icon: Ionicons.moon,
                      bgColor: Colors.purple.shade100,
                      iconColor: Colors.purple,
                      value: isDarkMode,
                      onTap: (value) {
                        setState(() {
                          isDarkMode = value;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SettingItem(
                      title: "Help",
                      icon: Ionicons.help_circle_outline,
                      bgColor: Colors.green.shade100,
                      iconColor: Colors.black,
                      onTap: () {},
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SettingItem(
                      title: "LogOut",
                      icon: Ionicons.log_out,
                      bgColor: Colors.red.shade100,
                      iconColor: Colors.red,
                      onTap: () {
                        signUserOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SplashScreen(onTap: () {
                              // Define the action for onTap here
                              print("Button tapped");
                            }),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sign out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }
}
