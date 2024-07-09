import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qlmoney/data/money.dart';
import 'package:intl/intl.dart'; // Thêm thư viện intl để định dạng ngày

class FirebaseService {
  Future<List<Money>> getMoneyData() async {
    final user = FirebaseAuth.instance.currentUser;
    List<Money> danhSachGiaoDich = [];
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
        var categorySnapshot =
            snapshot.snapshot.value as Map<dynamic, dynamic>?;

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
            String time = value['date'];
            String name = value['name'];
            String type = value['type'];
            String price = value['price'];

            // Chuyển đổi giá trị date từ Firebase thành DateTime
            DateFormat dateFormat =
                DateFormat('dd/MM/yy'); // Định dạng ngày từ Firebase
            DateTime transactionDate = dateFormat.parse(time);
            DateTime today = DateTime.now();
            DateTime todayStart = DateTime(
                today.year, today.month, today.day); // Ngày hôm nay bắt đầu
            DateTime todayEnd = DateTime(today.year, today.month, today.day, 23,
                59, 59); // Ngày hôm nay kết thúc

            // So sánh ngày giao dịch với ngày hôm nay
            if (transactionDate.isAtSameMomentAs(todayStart) ||
                (transactionDate.isAfter(todayStart) &&
                    transactionDate.isBefore(todayEnd))) {
              Money money = Money(
                icon: categoryIcon,
                nameCategory: categoryName,
                name: name,
                time: time,
                type: type,
                price: price,
              );

              danhSachGiaoDich.add(money);
            }
          });
        }
      } catch (error) {
        print('Lỗi khi lấy dữ liệu giao dịch: $error');
        // Xử lý lỗi nếu có
        throw error; // Ném ngoại lệ để cho phép người gọi xử lý
      }
    }
    print(danhSachGiaoDich);
    return danhSachGiaoDich;
  }

  // tong thu toan bo
  Future<int> totalIncome() async {
    final user = FirebaseAuth.instance.currentUser;
    int tongThu = 0;
    if (user != null) {
      try {
        DatabaseEvent thuchi = await FirebaseDatabase.instance
            .reference()
            .child('users')
            .child(user.uid)
            .child('khoanthuchi')
            .once();

        // Lấy dữ liệu từ snapshot
        var snapshotValue = thuchi.snapshot.value as Map<dynamic, dynamic>?;

        if (snapshotValue != null) {
          // Duyệt qua mỗi phần tử trong snapshotValue
          snapshotValue.forEach((key, value) {
            String type =
                value['type']; // Đảm bảo rằng bạn lấy đúng trường 'type'
            String priceStr =
                value['price']; // Đảm bảo rằng bạn lấy đúng trường 'price'

            // Chuyển đổi price từ String sang int
            int price = int.parse(priceStr);

            if (type == "Income") {
              tongThu += price;
            }
          });
        }
        print(tongThu);
      } catch (error) {
        print('Lỗi khi lấy danh sách categories từ Firebase: $error');
        // Xử lý lỗi nếu có
      }
    }
    return tongThu;
  }

  // lay ra tong thu trong ngay hom do
  Future<int> getPriceIncomeInDay() async {
    final user = FirebaseAuth.instance.currentUser;
    int tongThu = 0;
    if (user != null) {
      try {
        DatabaseEvent thuchi = await FirebaseDatabase.instance
            .reference()
            .child('users')
            .child(user.uid)
            .child('khoanthuchi')
            .once();

        // Lấy dữ liệu từ snapshot
        var snapshotValue = thuchi.snapshot.value as Map<dynamic, dynamic>?;

        if (snapshotValue != null) {
          // Duyệt qua mỗi phần tử trong snapshotValue
          snapshotValue.forEach((key, value) {
            // Lấy dữ liệu từ mỗi phần tử và thêm vào danh sách categories
            String dateThu = value['date'];
            String type =
                value['type']; // Đảm bảo rằng bạn lấy đúng trường 'type'
            String priceStr =
                value['price']; // Đảm bảo rằng bạn lấy đúng trường 'price'

            // Chuyển đổi price từ String sang int
            int price = int.parse(priceStr);

            DateFormat dateFormat =
                DateFormat('dd/MM/yy'); // Định dạng ngày từ Firebase
            DateTime transactionDate = dateFormat.parse(dateThu);
            DateTime today = DateTime.now();
            DateTime todayStart = DateTime(
                today.year, today.month, today.day); // Ngày hôm nay bắt đầu
            DateTime todayEnd = DateTime(today.year, today.month, today.day, 23,
                59, 59); // Ngày hôm nay kết thúc

            if (type == "Income" &&
                (transactionDate.isAtSameMomentAs(todayStart) ||
                    (transactionDate.isAfter(todayStart) &&
                        transactionDate.isBefore(todayEnd)))) {
              tongThu += price;
            }
          });
        }
        print(tongThu);
      } catch (error) {
        print('Lỗi khi lấy danh sách categories từ Firebase: $error');
        // Xử lý lỗi nếu có
      }
    }
    return tongThu;
  }

//   lay tong chi trong ngay hom do
  Future<int> getPriceExpenseInDay() async {
    final user = FirebaseAuth.instance.currentUser;
    int tongChi = 0;
    if (user != null) {
      try {
        DatabaseEvent thuchi = await FirebaseDatabase.instance
            .reference()
            .child('users')
            .child(user.uid)
            .child('khoanthuchi')
            .once();

        // Lấy dữ liệu từ snapshot
        var snapshotValue = thuchi.snapshot.value as Map<dynamic, dynamic>?;

        if (snapshotValue != null) {
          // Duyệt qua mỗi phần tử trong snapshotValue
          snapshotValue.forEach((key, value) {
            // Lấy dữ liệu từ mỗi phần tử và thêm vào danh sách categories
            String dateThu = value['date'];
            String type =
                value['type']; // Đảm bảo rằng bạn lấy đúng trường 'type'
            String priceStr =
                value['price']; // Đảm bảo rằng bạn lấy đúng trường 'price'

            // Chuyển đổi price từ String sang int
            int price = int.parse(priceStr);

            DateFormat dateFormat =
                DateFormat('dd/MM/yy'); // Định dạng ngày từ Firebase
            DateTime transactionDate = dateFormat.parse(dateThu);
            DateTime today = DateTime.now();
            DateTime todayStart = DateTime(
                today.year, today.month, today.day); // Ngày hôm nay bắt đầu
            DateTime todayEnd = DateTime(today.year, today.month, today.day, 23,
                59, 59); // Ngày hôm nay kết thúc

            if (type == "Expense" &&
                (transactionDate.isAtSameMomentAs(todayStart) ||
                    (transactionDate.isAfter(todayStart) &&
                        transactionDate.isBefore(todayEnd)))) {
              tongChi += price;
            }
          });
        }
        print(tongChi);
      } catch (error) {
        print('Lỗi khi lấy danh sách categories từ Firebase: $error');
        // Xử lý lỗi nếu có
      }
    }
    return tongChi;
  }

  // thong_ke
  Future<List<Money>> thongKe() async {
    final user = FirebaseAuth.instance.currentUser;
    List<Money> danhSachGiaoDich = [];
    if (user != null) {
      try {
        DatabaseReference moneyRef = FirebaseDatabase.instance
            .reference()
            .child('users')
            .child(user.uid)
            .child('khoanthuchi');

        DatabaseReference categoryRef = FirebaseDatabase.instance
            .reference()
            .child('users')
            .child(user.uid)
            .child('typecategorys');

        DataSnapshot moneySnapshot =
            await moneyRef.once().then((snapshot) => snapshot.snapshot);
        DataSnapshot categorySnapshot =
            await categoryRef.once().then((snapshot) => snapshot.snapshot);

        if (moneySnapshot.value != null && categorySnapshot.value != null) {
          Map<dynamic, dynamic> moneyData =
              moneySnapshot.value as Map<dynamic, dynamic>;
          Map<dynamic, dynamic> categoryData =
              categorySnapshot.value as Map<dynamic, dynamic>;

          moneyData.forEach((key, value) {
            String categoryIcon = '';
            String categoryName = '';
            String categoryId = value['category_id'] ?? '';

            categoryData.forEach((key, catValue) {
              if (catValue['id'] == categoryId) {
                categoryName = catValue['name'] ?? '';
                categoryIcon = catValue['icon'] ?? '';
              }
            });

            String time = value['date'] ?? '';
            String name = value['name'] ?? '';
            String type = value['type'] ?? '';
            String price = value['price'] ?? '0';
            Money money = Money(
              icon: categoryIcon,
              nameCategory: categoryName,
              name: name,
              time: time,
              type: type,
              price: price,
            );

            danhSachGiaoDich.add(money);
          });
        }
      } catch (error) {
        print('Lỗi khi lấy dữ liệu giao dịch: $error');
        throw error;
      }
    }
    return danhSachGiaoDich;
  }
}
