import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qlmoney/screen/screen_started.dart';




import 'data/login_main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: const FirebaseOptions(
  //     apiKey: "AIzaSyAkHAJ5pkXdXer8wv_D2BI0mtxdXpG_G-g",
  //     appId: "1:963788238016:android:789abbd4ceb93ecd7b1125",
  //     messagingSenderId: "XXX",
  //     projectId: "quanlychitieu-bac0a",
  //     databaseURL: 'https://quanlychitieu-bac0a-default-rtdb.asia-southeast1.firebasedatabase.app/',
  //   ),
  // );
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAkHAJ5pkXdXer8wv_D2BI0mtxdXpG_G-g',
        authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
        databaseURL: 'https://quanlychitieu-bac0a-default-rtdb.asia-southeast1.firebasedatabase.app/',
        projectId: 'quanlychitieu-bac0a',
        storageBucket: 'gs://quanlychitieu-bac0a.appspot.com',
        messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
        appId: '1:963788238016:android:789abbd4ceb93ecd7b1125',
        measurementId: 'YOUR_MEASUREMENT_ID',
      )
  );
  runApp(const MyApp());
  AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
            channelKey: 'Remind_1',
            channelName: 'Remind_Notification',
            channelDescription: "Ban co 1 nhac nho!")
      ],
      debug: true);

  runApp(const MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Money management Application',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       //home: const LoginMainPage(),
//       home: SplashScreen(
//         onTap: () {
//           // Define the action for onTap here
//           print("Button tapped");
//         },
//       ),
//     );
//   }
// }
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Money Management',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      home: SplashScreen(
        onTap: () {},
      ),
    );
  }
}