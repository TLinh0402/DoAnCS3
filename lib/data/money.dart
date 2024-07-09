class Money {
  String? id;
  String? icon;
  String? nameCategory;
  String? name;
  String? time;
  String? type;
  String? price;

  Money({
    this.id,
    this.icon,
    this.nameCategory,
    this.name,
    this.time,
    this.type,
    this.price,
  });

  factory Money.fromJson(Map<String, dynamic> json) {
    return Money(
      id: json['id'],
      icon: json['icon'],
      nameCategory: json['name'],
      name: json['name'],
      time: json['date'],
      type: json['type'],
      price: json['price'],
    );
  }
}
