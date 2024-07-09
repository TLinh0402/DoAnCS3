import 'package:flutter/material.dart';

class CategoryList extends StatelessWidget {
  final String? name;
  final String? icon;
  final String? totalPrice;

  CategoryList({
    required this.name,
    required this.icon,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(12),
          color: Colors.grey[200],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 60,
                    child: Image.asset("assets/image/$icon.png"),
                  ),
                  // ignore: prefer_const_constructors
                  SizedBox(
                    width: 20,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        "Category",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.green[300],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  name!,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ),
              Text("\$ " + totalPrice.toString()),
            ],
          ),
        ),
      ),
    );
  }
}
