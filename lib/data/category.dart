class Category {
  String? icon;
  String? name;
  String? totalPrice;

  Category({
    this.icon,
    this.name,
    this.totalPrice,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      icon: json['icon'],
      name: json['name'],
      totalPrice: json['totalPrice'],
    );
  }
}
