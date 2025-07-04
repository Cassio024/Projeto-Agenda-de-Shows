// lib/models/user_model.dart

class User {
  int? id;
  String name;
  String email;
  String password;
  DateTime birthDate; // NOVO CAMPO

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.birthDate, // NOVO CAMPO
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'birthDate': birthDate.toIso8601String(), // NOVO CAMPO
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      birthDate: DateTime.parse(map['birthDate']), // NOVO CAMPO
    );
  }
}
