class UserProfile {
  String? id;
  String name;
  String gender;
  int age;
  String email;

  UserProfile({
    this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender,
      'age': age,
      'email': email,
    };
  }

  static UserProfile fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      gender: json['gender'],
      age: json['age'],
      email: json['email'],
    );
  }
}
