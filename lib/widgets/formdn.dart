import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qlmoney/screen/bottom_navigation_bar.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SignForm(),
      ),
    );
  }
}

class SignForm extends StatefulWidget {
  const SignForm({Key? key}) : super(key: key);

  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showpass = false;
  bool _showErrorMessage = false;

  Future<void> signIn() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        Navigator.pop(context); // Đóng dialog loading
        // Điều hướng đến trang HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavigationPage()),
        );
      } catch (e) {
        Navigator.pop(context);
        setState(() {
          _showErrorMessage = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: "Email",
              hintText: "Enter your email",

            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: !_showpass,
            decoration: InputDecoration(
              labelText: "Password",
              hintText: "Enter your password",
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _showpass = !_showpass;
                  });
                },
                child: Icon(
                  _showpass ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              } else if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          if (_showErrorMessage)
            const Text(
              "Invalid email or password",
              style: TextStyle(color: Colors.red),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: signIn,
            child: const Text("Sign In"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
