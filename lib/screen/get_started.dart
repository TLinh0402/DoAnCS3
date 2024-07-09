import 'package:flutter/material.dart';

class SplashContent extends StatefulWidget {
  const SplashContent({
    Key? key,
    this.text,
    this.image,
    required Color color,
  }) : super(key: key);
  final String? text, image;
  static const String routeName =
      '/splash_content'; // Định nghĩa routeName ở đây

  @override
  State<SplashContent> createState() => _SplashContentState();
}

class _SplashContentState extends State<SplashContent> {
  get kPrimaryColor => null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Spacer(),
        const Text(
          "APP QLTC",
          style: TextStyle(
            fontSize: 32,
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          widget.text!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black,
            // fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(flex: 2),
        Image.asset(
          widget.image!,
          height: 300,
          width: 260,
        ),
      ],
    );
  }
}
