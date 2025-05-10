import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:qlmoney/data/category.dart';
import 'package:qlmoney/data/money.dart';
import 'package:qlmoney/data/list_price_find.dart';

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
    _layDuLieu(DateTime(1970));
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
        return (money.name ?? '').toLowerCase().contains(query);
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
        backgroundColor: Colors.blueAccent,
        title: const Text("All Income & Expense"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Ionicons.chevron_back_outline),
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _filterByName(),
                        decoration: const InputDecoration(
                          hintText: "Search income or expense",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today, color: Colors.blueAccent),
                      onPressed: _showDatePicker,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                itemCount: categoryList.length,
                itemBuilder: (context, index) {
                  final category = categoryList[index];
                  return GestureDetector(
                    onTap: () => _filterByCategory(category),
                    child: Container(
                      width: 110,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/image/${category.icon ?? "default"}.png', height: 40,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported)),
                          const SizedBox(height: 8),
                          Text(category.name ?? 'No name', style: const TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text("\$${category.totalPrice ?? 0}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text("Income & Expense", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset('assets/image/${item.icon ?? "default"}.png',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported)),
                        ),
                        title: Text(item.name ?? 'No name', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(item.time ?? 'Unknown time'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${(item.type ?? 'Expense') == 'Income' ? '+\$' : '-\$'}${item.price ?? '0'}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: (item.type ?? 'Expense') == 'Income' ? Colors.green : Colors.pink,
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditDialog(item);
                                } else if (value == 'delete') {
                                  _showDeleteConfirmationDialog(item);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                                const PopupMenuItem(value: 'delete', child: Text('Xóa')),
                              ],
                            )
                          ],
                        ),
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

  Future<void> _showDeleteConfirmationDialog(Money money) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 245, 252, 255),
          title: const Text('Delete Confirmation', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          content: const Text('Do you really want to delete this item?'),
          actions: <Widget>[
            TextButton(child: const Text('Cancel', style: TextStyle(color: Colors.grey)), onPressed: () => Navigator.of(context).pop()),
            TextButton(child: const Text('Delete', style: TextStyle(color: Colors.red)), onPressed: () {
              _deleteMoneyItem(money);
              Navigator.of(context).pop();
            }),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(Money money) async {
    TextEditingController nameController = TextEditingController(text: money.name);
    TextEditingController priceController = TextEditingController(text: money.price);
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sửa giao dịch'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Giá tiền'), keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) selectedDate = picked;
                },
                child: const Text('Chọn ngày'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null && money.id != null) {
                  final ref = FirebaseDatabase.instance.ref('users/${user.uid}/khoanthuchi/${money.id}');
                  await ref.update({
                    'name': nameController.text.trim(),
                    'price': priceController.text.trim(),
                    'date': "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}"
                  });
                  await _layDuLieu(DateTime(1970));
                  Navigator.pop(context);
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMoneyItem(Money money) async {
    final user = _auth.currentUser;
    if (user != null) {
      DatabaseReference ref = _database.ref().child('users/${user.uid}/khoanthuchi/${money.id}');
      try {
        await ref.remove();
        setState(() {
          khoanThuChiList.remove(money);
          filteredList.remove(money);
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted successfully')));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting item: $error')));
      }
    }
  }

  Future<void> _showDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      _layDuLieu(pickedDate);
    }
  }
}
