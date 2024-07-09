import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();

  bool _showpass = false;
  bool _showErrorMessage = false; // Thêm biến để kiểm soát hiển thị lỗi

// singUp User
  Future signUp() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
    try {
      // check mk nhap lai trung voi mk chua
      if (_passwordController.text == _confirmpasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // show error
        setState(() {
          _showErrorMessage = true;
        });
      }

      Navigator.pop(context);
    } catch (e) {
      // Nếu đăng nhập thất bại, hiển thị thông báo lỗi
      setState(() {
        _showErrorMessage = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  var _usernameerr = "Tài khoản không hợp lệ";
  var _passworderr = "Mật khẩu không hợp lệ, phải có ít nhất 6 ký tự";
  var _userInvalid = false;
  var _passInvalid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.blue, Colors.red],
            ),
          ),
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                width: 400,
                padding: EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset(
                      "assets/image/logo.png",
                      height: 80,
                      width: 80,
                    ),
                    Text(
                      "Let\'s create an account for you!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Open Sans',
                        color: Colors.black, // Thêm màu cho chữ
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        errorText: _userInvalid ? _usernameerr : null,
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            style: TextStyle(fontSize: 18, color: Colors.black),
                            controller: _passwordController,
                            obscureText: !_showpass,
                            decoration: InputDecoration(
                              labelText: "Mật khẩu",
                              errorText: _passInvalid ? _passworderr : null,
                              labelStyle:
                                  TextStyle(color: Colors.grey, fontSize: 15),
                              suffixIcon: GestureDetector(
                                onTap: onShowPass,
                                child: Icon(
                                  _showpass
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.blue, // Màu của icon
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            style: TextStyle(fontSize: 18, color: Colors.black),
                            controller: _confirmpasswordController,
                            obscureText: !_showpass,
                            decoration: InputDecoration(
                              labelText: "Nhập lại mật khẩu",
                              errorText: _passInvalid ? _passworderr : null,
                              labelStyle:
                                  TextStyle(color: Colors.grey, fontSize: 15),
                              suffixIcon: GestureDetector(
                                onTap: onShowPass,
                                child: Icon(
                                  _showpass
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.blue, // Màu của icon
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      height: _showErrorMessage ? 50 : 0,
                      child: _showErrorMessage
                          ? Text(
                              "Tên người dùng hoặc mật khẩu không đúng.",
                              style: TextStyle(color: Colors.red),
                            )
                          : null,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 70, 152, 233),
                        ),
                      ),
                      onPressed: onSignUpClicked,
                      child: Text(
                        "ĐĂNG KÝ",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            "Đã có tài khoản? Đăng nhập",
                            style:
                                TextStyle(fontSize: 18, color: Colors.yellow),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onShowPass() {
    setState(() {
      _showpass = !_showpass;
    });
  }

  void onSignUpClicked() {
    setState(() {
      if (_emailController.text.length < 6 ||
          !_emailController.text.contains("@")) {
        _userInvalid = true;
      } else {
        _userInvalid = false;
      }
      if (_passwordController.text.length < 6) {
        _passInvalid = true;
      } else {
        _passInvalid = false;
      }
      if (!_userInvalid && !_passInvalid) {
        signUp();
      }
    });
  }
}
