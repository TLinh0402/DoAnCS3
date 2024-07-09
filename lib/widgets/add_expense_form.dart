import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:qlmoney/screen/bottom_navigation_bar.dart';

class AddExpenseForm extends StatefulWidget {
  const AddExpenseForm({Key? key});

  @override
  State<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<AddExpenseForm> {
  TextEditingController expenseNameController = TextEditingController();
  TextEditingController expensePriceController = TextEditingController();
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

  List<String> categoriesIcons = [
    'salary',
    'food',
    'home',
    'pet',
    'shopping',
    'tech',
    'travel',
    'bill',
  ];

  String? selectedCategory;
  List<String> categories = [];

  String _selectedValue = 'Expense';

  @override
  void initState() {
    dateController.text = DateFormat('dd/MM/yy').format(DateTime.now());
    super.initState();
    getCategoryFromFirebase();
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
                'assets/image/add.jpg', // Đường dẫn tới hình ảnh của bạn
                fit: BoxFit.cover,
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // const Text(
                        //   'Add Expense',
                        //   style: TextStyle(
                        //       fontSize: 22,
                        //       fontWeight: FontWeight.bold,
                        //       color: Colors.orange),
                        // ),
                        const SizedBox(
                          height: 120,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 180,
                              // width: MediaQuery.of(context).size.width * 0.7,
                              child: TextFormField(
                                controller: expenseNameController,
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
                                  hintText: 'Enter expense name',
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              width: 185,
                              // width: MediaQuery.of(context).size.width * 0.7,
                              child: TextFormField(
                                key: _formKey,
                                controller: expensePriceController,
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d*')),
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
                                  hintText: 'Enter expense price',
                                ),
                                validator: _validatePrice,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        // chọn tên loại chi tiêu
                        TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          controller: typeController,
                          readOnly: true,
                          onTap: () {
                            // Hiển thị menu thả xuống khi nhấn vào TextField
                            showDialog(
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  title: const Text('Select Category'),
                                  content: DropdownButtonFormField<String>(
                                    value: selectedCategory,
                                    items: categories.map((category) {
                                      return DropdownMenuItem<String>(
                                        value: category,
                                        child: Text(category),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCategory = value;
                                        typeController.text = value!;
                                      });
                                      Navigator.pop(
                                          ctx); // Đóng hộp thoại sau khi chọn
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      prefixIcon: const Icon(
                                        FontAwesomeIcons.list,
                                        size: 16,
                                        color: Colors.blue,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      hintText: 'Name Type',
                                    ),
                                    dropdownColor: Colors.white,
                                  ),
                                );
                              },
                            );
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.blue[50],
                            prefixIcon: const Icon(FontAwesomeIcons.list,
                                size: 16, color: Colors.blue),
                            suffixIcon: IconButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (ctx) {
                                      bool isExpense = false;
                                      String iconSelected = '';
                                      TextEditingController nameAddTypeController =
                                      TextEditingController();
                                      return StatefulBuilder(
                                          builder: (context, setState) {
                                            return AlertDialog(
                                              title: const Text('Add Type Category'),
                                              backgroundColor: const Color.fromARGB(
                                                  255, 167, 225, 245),
                                              content: SizedBox(
                                                width: MediaQuery.of(context).size.width,
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    TextFormField(
                                                      controller: nameAddTypeController,
                                                      textAlignVertical:
                                                      TextAlignVertical.center,
                                                      decoration: InputDecoration(
                                                        isDense: true,
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        border: OutlineInputBorder(
                                                          borderRadius:
                                                          BorderRadius.circular(12),
                                                          borderSide: BorderSide.none,
                                                        ),
                                                        hintText: 'Name',
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 16,
                                                    ),
                                                    TextFormField(
                                                      onTap: () {
                                                        setState(() {
                                                          isExpense = !isExpense;
                                                        });
                                                      },
                                                      textAlignVertical:
                                                      TextAlignVertical.center,
                                                      readOnly: true,
                                                      decoration: InputDecoration(
                                                        isDense: true,
                                                        filled: true,
                                                        suffixIcon: const Icon(
                                                          CupertinoIcons.chevron_down,
                                                          size: 12,
                                                        ),
                                                        fillColor: Colors.white,
                                                        border: OutlineInputBorder(
                                                          borderRadius: isExpense
                                                              ? const BorderRadius
                                                              .vertical(
                                                            top:
                                                            Radius.circular(12),
                                                          )
                                                              : BorderRadius.circular(12),
                                                          borderSide: BorderSide.none,
                                                        ),
                                                        hintText: 'Icon',
                                                      ),
                                                    ),
                                                    isExpense
                                                        ? Container(
                                                      width: MediaQuery.of(context)
                                                          .size
                                                          .width,
                                                      height: 200,
                                                      decoration:
                                                      const BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                        BorderRadius.vertical(
                                                          bottom:
                                                          Radius.circular(12),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                        child: GridView.builder(
                                                          gridDelegate:
                                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: 3,
                                                            crossAxisSpacing: 5,
                                                            mainAxisSpacing: 5,
                                                          ),
                                                          itemCount: categoriesIcons
                                                              .length,
                                                          itemBuilder:
                                                              (context, int i) {
                                                            return GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  iconSelected =
                                                                  categoriesIcons[
                                                                  i];
                                                                });
                                                              },
                                                              child: Container(
                                                                  width: 50,
                                                                  height: 50,
                                                                  decoration:
                                                                  BoxDecoration(
                                                                      border: Border.all(
                                                                          width:
                                                                          3,
                                                                          color: iconSelected == categoriesIcons[i]
                                                                              ? Colors
                                                                              .green
                                                                              : Colors
                                                                              .grey),
                                                                      borderRadius:
                                                                      BorderRadius.circular(
                                                                          12),
                                                                      image:
                                                                      DecorationImage(
                                                                        image:
                                                                        AssetImage(
                                                                          'assets/image/${categoriesIcons[i]}.png',
                                                                        ),
                                                                      ))),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    )
                                                        : Container(),
                                                    const SizedBox(
                                                      height: 16,
                                                    ),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      height: kToolbarHeight,
                                                      child: TextButton(
                                                        onPressed: () {
                                                          if (nameAddTypeController
                                                              .text.isNotEmpty &&
                                                              iconSelected.isNotEmpty) {
                                                            var newTypeName =
                                                            nameAddTypeController.text
                                                                .toString();
                                                            _saveCategory(newTypeName,
                                                                iconSelected);
                                                            Navigator.pop(ctx);
                                                          }
                                                        },
                                                        style: TextButton.styleFrom(
                                                          backgroundColor: Colors.black,
                                                          padding:
                                                          const EdgeInsets.all(16),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius.circular(12),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          'Save',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 22,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                    });
                              },
                              icon: const Icon(FontAwesomeIcons.plus,
                                  size: 16,
                                  color: Color.fromARGB(255, 158, 158, 158)),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintText: 'Category',
                          ),
                        ),
                        const SizedBox(
                          height: 16,
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
                          // width: double.infinity,
                          width: 100,
                          height: kToolbarHeight,
                          child: TextButton(
                            onPressed: () {
                              _saveChi(
                                  expenseNameController.text,
                                  expensePriceController.text,
                                  selectedCategory!,
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

  // Ham luu category
  Future<void> _saveCategory(String nameNewType, String icon) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DatabaseReference ref = FirebaseDatabase.instance
            .reference()
            .child('users')
            .child(user.uid)
            .child('typecategorys')
            .push();
        String typeId =
            ref.key ?? ''; // Sử dụng ref.key trực tiếp thay vì nullable
        await ref.set({
          'id': typeId,
          'name': nameNewType,
          'icon': icon,
        });
        setState(() {
          categories.add(nameNewType);
          // Thêm thông tin loại category mới vào danh sách hiện có
        });
      } catch (error) {
        print('Lỗi khi lưu category: $error');
        // Xử lý lỗi ở đây, như hiển thị một snackbar hoặc hộp thoại cảnh báo
      }
    }
  }

//   ham lay categories tu Firebase
  Future<void> getCategoryFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DatabaseEvent snapshot = await FirebaseDatabase.instance
            .reference()
            .child('users')
            .child(user.uid)
            .child('typecategorys')
            .once();

        // Lấy dữ liệu từ snapshot
        var snapshotValue = snapshot.snapshot.value as Map<dynamic, dynamic>?;

        if (snapshotValue != null) {
          // Duyệt qua mỗi phần tử trong snapshotValue
          snapshotValue.forEach((key, value) {
            // Lấy dữ liệu từ mỗi phần tử và thêm vào danh sách categories
            String categoryName = value['name'];
            if (categoryName != "Lương") {
              categories.add(categoryName);
            }
          });

          setState(() {
            // Cập nhật danh sách categories và gọi setState
            categories = categories;
          });
        }
      } catch (error) {
        print('Lỗi khi lấy danh sách categories từ Firebase: $error');
        // Xử lý lỗi nếu có
      }
    }
  }

//   Ham luu thu || chi
  Future<void> _saveChi(String name, String price, String categoryName,
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
