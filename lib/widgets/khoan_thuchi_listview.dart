import 'package:flutter/material.dart';
import 'package:qlmoney/data/money.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class KhoanThuChiListview extends StatelessWidget {
  final Money money;

  KhoanThuChiListview({
    required this.money,
  });

  @override
  Widget build(BuildContext context) {
    String? name = money.name;
    String? icon = money.icon;
    String? time = money.time;
    String? price = money.price;
    String? type = money.type;
    String? id = money.id; // <- Quan trọng để xóa

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          border: Border.all(color: Colors.blue.shade100),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Icon và thông tin
            Expanded(
              child: Row(
                children: [
                  ClipRRect(
                    child: Container(
                      height: 50,
                      padding: EdgeInsets.all(8),
                      child: Image.asset(
                        "assets/image/$icon.png",
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          time ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.blueGrey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Giá tiền + nút
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ((type == 'Income') ? "+\$ " : "-\$ ") + (price ?? '0'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: (type == 'Income') ? Colors.green : Colors.pink,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, size: 20, color: Colors.orange),
                      onPressed: () {
                        // TODO: mở dialog sửa hoặc chuyển sang trang sửa
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null && id != null) {
                          await FirebaseDatabase.instance
                              .ref('users/${user.uid}/khoanthuchi')
                              .child(id)
                              .remove();
                        }
                      },
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
