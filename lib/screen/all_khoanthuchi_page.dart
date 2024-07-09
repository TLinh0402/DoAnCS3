import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:qlmoney/data/category.dart';
import 'package:qlmoney/data/money.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qlmoney/widgets/category_list.dart';
import 'package:qlmoney/widgets/khoan_thuchi_listview.dart';
import 'package:qlmoney/data/list_price_find.dart'; // Import tệp dịch vụ

class AllKhoanThuChi extends StatefulWidget {
  const AllKhoanThuChi({Key? key}) : super(key: key);

  @override
  State<AllKhoanThuChi> createState() => _AllKhoanThuChiState();
}

class _AllKhoanThuChiState extends State<AllKhoanThuChi> {
  List<Category> categoryList = [];
  List<Money> khoanThuChiList = [];
  List<Money> filteredList = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final TextEditingController _searchController = TextEditingController();
  Category? selectedCategory;

  @override
  void initState() {
    super.initState();
    // Lấy dữ liệu ban đầu cho tất cả các ngày
    _layDuLieu(
        DateTime(1970)); // Chọn một ngày ở quá khứ để lấy tất cả các giao dịch
    _searchController.addListener(_filterByName);
  }

  Future<void> _layDuLieu(DateTime? selectedDate) async {
    List<Money> data = await layKhoanThuChi(selectedDate!);
    List<Category> dataCate = await layCategory();
    setState(() {
      khoanThuChiList = data;
      filteredList = data;
      categoryList = dataCate;
    });
  }

  void _filterByName() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      filteredList = khoanThuChiList.where((money) {
        return money.name!.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _filterByCategory(Category category) {
    setState(() {
      selectedCategory = category;
      filteredList = khoanThuChiList
          .where((money) => money.nameCategory == category.name)
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 25.0),
              child: Text("All Income and Expense",
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue,
                  )),
            ),
            const SizedBox(
              height: 25,
            ),

            // search bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Container(
                              height: 30,
                              child: Icon(Icons.search),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onSubmitted: (value) {
                                _filterByName();
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Search name Income or Expense!",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      _showDatePicker(); // Gọi hàm hiển thị lịch
                    },
                    child: Container(
                      height: 50,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_month,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 25.0),
              child: Text("Category",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
            ),
            const SizedBox(
              height: 15,
            ),

            Container(
              height: 160,
              child: ListView.builder(
                  itemCount: categoryList.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _filterByCategory(categoryList[index]),
                      child: CategoryList(
                          name: categoryList[index].name,
                          icon: categoryList[index].icon,
                          totalPrice: categoryList[index].totalPrice),
                    );
                  }),
            ),

            // Khoản thu và khoản chi
            const SizedBox(
              height: 30,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 25.0),
              child: Text("Income and Expense",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      // Sử dụng GestureDetector để bắt sự kiện nhấn giữ
                      onLongPress: () {
                        _showDeleteConfirmationDialog(filteredList[index]);
                      },
                      child: KhoanThuChiListview(
                        name: filteredList[index].name,
                        icon: filteredList[index].icon,
                        date: filteredList[index].time,
                        price: filteredList[index].price,
                        type: filteredList[index].type,
                        money: filteredList[index],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm hiển thị hộp thoại xác nhận xóa
  Future<void> _showDeleteConfirmationDialog(Money money) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Click ngoài hộp thoại không đóng hộp thoại
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 212, 239, 251),
          title: const Text(
            'Xác nhận xóa',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bạn có muốn xóa mục này không?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Hủy',
                style:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
            ),
            TextButton(
              child: const Text(
                'Xóa',
                style:
                TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                // Thực hiện xóa và đóng hộp thoại
                _deleteMoneyItem(money);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Hàm xóa mục khoản thu chi
  Future<void> _deleteMoneyItem(Money money) async {
    final user = _auth.currentUser;
    if (user != null) {
      DatabaseReference databaseReference = FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(user.uid)
          .child('khoanthuchi')
          .child(money.id!);
      // Thực hiện xóa tài liệu từ Realtime Database
      databaseReference.remove().then((value) {
        // Xóa thành công, cập nhật giao diện người dùng
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa mục')),
        );

        // Cập nhật giao diện người dùng sau khi xóa thành công
        setState(() {
          khoanThuChiList.remove(money);
          filteredList.remove(money);
        });
      }).catchError((error) {
        // Xử lý lỗi nếu có
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa mục: $error')),
        );
      });
    }
  }

  // Ham hien thi Calender
  Future<void> _showDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      // Lấy dữ liệu cho ngày đã chọn
      _layDuLieu(pickedDate);
    }
  }
}
