import 'package:flutter/material.dart';
import 'package:qlmoney/data/money.dart';

class KhoanThuChiListview extends StatelessWidget {
  final Money money;

  KhoanThuChiListview(
      {required this.money,
      String? name,
      String? icon,
      String? date,
      String? price,
      String? type});

  @override
  Widget build(BuildContext context) {
    String? name = money.name;
    String? icon = money.icon;
    String? time = money.time;
    String? price = money.price;
    String? type = money.type;

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ClipRRect(
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.all(8),
                    child: Image.asset("assets/image/$icon.png"),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name!,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      time!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              ((type) == 'Income' ? "+\$ " : "-\$ ") + price!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: (type) == 'Income' ? Colors.green : Colors.pink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
