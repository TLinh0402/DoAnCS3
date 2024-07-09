import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:qlmoney/data/money.dart';
import 'package:qlmoney/data/category.dart';

Future<List<Money>> layKhoanThuChi(DateTime selectedDate) async {
  final user = FirebaseAuth.instance.currentUser;
  List<Money> danhSachThuChi = [];
  if (user != null) {
    try {
      DatabaseEvent _moneyRef = await FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(user.uid)
          .child('khoanthuchi')
          .once();
      DatabaseEvent snapshot = await FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(user.uid)
          .child('typecategorys')
          .once();

      // Lấy dữ liệu từ Firebase một lần
      var moneySnapshot = _moneyRef.snapshot.value as Map<dynamic, dynamic>?;
      var categorySnapshot = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (moneySnapshot != null && categorySnapshot != null) {
        // Lưu trữ dữ liệu typecategorys trong một bản đồ với các ID loại làm khóa
        moneySnapshot.forEach((key, value) {
          // Lấy ID loại từ mỗi giao dịch và thêm vào danh sách
          String categoryIcon = '';
          String categoryName = '';
          String categoryId = value['category_id'];
          if (categorySnapshot != null) {
            categorySnapshot.forEach((key, categoryValue) {
              String id = categoryValue['id'];
              if (id == categoryId) {
                categoryName = categoryValue['name'];
                categoryIcon = categoryValue['icon'];
              }
            });
          }
          String id = value['id'];
          String time = value['date'];
          String name = value['name'];
          String type = value['type'];
          String price = value['price'];

          // Chuyển đổi giá trị date từ Firebase thành DateTime
          DateFormat dateFormat =
              DateFormat('dd/MM/yy'); // Định dạng ngày từ Firebase
          DateTime transactionDate = dateFormat.parse(time);

          if (selectedDate == DateTime(1970)) {
            Money money = Money(
              id: id,
              icon: categoryIcon,
              nameCategory: categoryName,
              name: name,
              time: time,
              type: type,
              price: price,
            );

            danhSachThuChi.add(money);
          } else {
            // Ngày bắt đầu và kết thúc của ngày đã chọn
            DateTime dayFindStart = DateTime(
                selectedDate.year, selectedDate.month, selectedDate.day);
            DateTime dayFindEnd = DateTime(selectedDate.year,
                selectedDate.month, selectedDate.day, 23, 59, 59);

            // So sánh ngày giao dịch với ngày đã chọn
            if (transactionDate.isAtSameMomentAs(dayFindStart) ||
                (transactionDate.isAfter(dayFindStart) &&
                    transactionDate.isBefore(dayFindEnd))) {
              Money money = Money(
                id: id,
                icon: categoryIcon,
                nameCategory: categoryName,
                name: name,
                time: time,
                type: type,
                price: price,
              );

              danhSachThuChi.add(money);
            }
          }
        });
      }
    } catch (error) {
      print('Lỗi khi lấy dữ liệu giao dịch: $error');
      // Xử lý lỗi nếu có
      throw error; // Ném ngoại lệ để cho phép người gọi xử lý
    }
  }
  // print(danhSachThuChi);
  return danhSachThuChi;
}

// Ham lay Category
Future<List<Category>> layCategory() async {
  List<Category> categories = [];
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
        for (var entry in snapshotValue.entries) {
          Map<dynamic, dynamic> categoryData = entry.value;

          String categoryName = categoryData['name'];
          String categoryIcon = categoryData['icon'];
          String categoryID = categoryData['id'];

          // Tìm kiếm category_id trong khoanthuchi
          DatabaseEvent khoanthuchiSnapshot = await FirebaseDatabase.instance
              .reference()
              .child('users')
              .child(user.uid)
              .child('khoanthuchi') // Sử dụng categoryID thay vì 'category_id'
              .once();

          var khoanthuchiValue =
              khoanthuchiSnapshot.snapshot.value as Map<dynamic, dynamic>?;
          double totalPrice = 0.0;

          // print("abc $khoanthuchiValue");

          if (khoanthuchiValue != null) {
            khoanthuchiValue.forEach((key, value) {
              if (value['category_id'] == categoryID) {
                // So sánh với 'category_id' của mỗi mục
                if (value['price'] != null) {
                  // Chuyển đổi giá trị price từ chuỗi thành double
                  try {
                    totalPrice += double.parse(value['price']);
                  } catch (e) {
                    print('Lỗi khi chuyển đổi giá trị price: $e');
                  }
                }
              }
            });
          }

          // Thêm totalPrice vào danh sách categories
          categories.add(Category(
            icon: categoryIcon,
            name: categoryName,
            totalPrice: totalPrice.toString(),
          ));
        }
      }
    } catch (error) {
      print('Lỗi khi lấy danh sách categories từ Firebase: $error');
      // Xử lý lỗi nếu có
    }
  }

  return categories;
}
