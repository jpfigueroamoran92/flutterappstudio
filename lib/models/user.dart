class User {
  final int id;
  final String name;
  final String? company; // Optional
  final String email;
  final String? phone; // Optional
  final String token;

  User({
    required this.id,
    required this.name,
    this.company,
    required this.email,
    this.phone,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      company: json['company'],
      email: json['email'],
      phone: json['phone'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company': company,
      'email': email,
      'phone': phone,
      'token': token,
    };
  }
}
