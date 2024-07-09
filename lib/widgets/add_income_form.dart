import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:qlmoney/screen/bottom_navigation_bar.dart';

class AddIncomeForm extends StatefulWidget {
  const AddIncomeForm({Key? key});

  @override
  State<AddIncomeForm> createState() => _AddIncomeFormState();
}

class _AddIncomeFormState extends State<AddIncomeForm> {
  TextEditingController incomeNameController = TextEditingController();
  TextEditingController incomePriceController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  // xac thuc price
  final _formKey = GlobalKey<FormState>();

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a price';
    }
    final double? price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Please enter a number greater than 0';
    }
    return null;
  }

  String selectedCategory = "Lương";

  String _selectedValue = 'Income';

  @override
  void initState() {
    dateController.text = DateFormat('dd/MM/yy').format(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/image/bgAddIncome.jpg', // Đường dẫn tới hình ảnh của bạn
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // const Text(
                //   'Add Income',
                //   style: TextStyle(
                //       fontSize: 22,
                //       fontWeight: FontWeight.bold,
                //       color: Colors.orange),
                // ),
                const SizedBox(
                  height: 120,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextFormField(
                    controller: incomeNameController,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.blue[50],
                      prefixIcon: const Icon(FontAwesomeIcons.tags,
                          size: 16, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      labelText: 'Name',
                      hintText: 'Enter income name',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  // width: MediaQuery.of(context).size.width * 0.7,
                  child: TextFormField(
                    key: _formKey,
                    controller: incomePriceController,
                    textAlignVertical: TextAlignVertical.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.blue[50],
                      prefixIcon: const Icon(FontAwesomeIcons.dollarSign,
                          size: 16, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      labelText: 'How much?',
                      hintText: 'Enter income price',
                    ),
                    validator: _validatePrice,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                // chon ngày tháng
                TextFormField(
                  controller: dateController,
                  textAlignVertical: TextAlignVertical.center,
                  readOnly: true,
                  onTap: () async {
                    DateTime? newDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.utc(2020,2,3),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );

                    if (newDate != null) {
                      setState(() {
                        dateController.text =
                            DateFormat('dd/MM/yyyy').format(newDate);
                        selectedDate = newDate;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blue[50],
                    prefixIcon: const Icon(FontAwesomeIcons.clock,
                        size: 16, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    hintText: 'Date',
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                SizedBox(
                  width: 100,
                  height: kToolbarHeight,
                  child: TextButton(
                    onPressed: () {
                      _saveThu(
                          incomeNameController.text,
                          incomePriceController.text,
                          selectedCategory,
                          dateController.text,
                          _selectedValue);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BottomNavigationPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 24, 221, 10),
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'SAVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
        ),
      ),
    );
  }

//   Ham luu thu
  Future<void> _saveThu(String name, String price, String categoryName,
      String date, String type) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Lấy category_id từ category_name
        String categoryId = await getCategoryID(categoryName);

        DatabaseReference refKhoanThuChi = FirebaseDatabase.instance
            .reference()
            .child('users')
            .child(user.uid)
            .child('khoanthuchi')
            .push();
        String khoanThuChiId = refKhoanThuChi.key ?? '';

        await refKhoanThuChi.set({
          'id': khoanThuChiId,
          'name': name,
          'price': price,
          'category_id': categoryId,
          'date': date,
          'type': type,
        });
      } catch (error) {
        print('Lỗi khi lưu khoản Chi: $error');
        // Xử lý lỗi ở đây, như hiển thị một snackbar hoặc hộp thoại cảnh báo
      }
    }
  }

// Hàm này để lấy category_id từ category_name
  Future<String> getCategoryID(String categoryName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DatabaseEvent snapshot = await FirebaseDatabase.instance
            .reference()
            .child('users')
            .child(user.uid)
            .child('typecategorys')
            .orderByChild('name')
            .equalTo(categoryName)
            .once();

        var snapshotValue = snapshot.snapshot.value as Map<dynamic, dynamic>?;

        if (snapshotValue != null) {
          // Lấy category_id từ snapshot
          String categoryId = snapshotValue.keys.first;
          return categoryId;
        } else {
          throw 'Không tìm thấy category_id cho category $categoryName';
        }
      } catch (error) {
        throw 'Lỗi khi lấy category_id từ Firebase: $error';
      }
    } else {
      throw 'Người dùng không hợp lệ';
    }
  }
}
