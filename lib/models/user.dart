// lib/models/user.dart

class User {
  final String namaLengkap;
  final String nik;
  final String email;
  final String alamat;
  final String nomorTelepon;
  final String username;
  final String password;

  User({
    required this.namaLengkap,
    required this.nik,
    required this.email,
    required this.alamat,
    required this.nomorTelepon,
    required this.username,
    required this.password,
  });

  // Convert User to Map untuk disimpan ke SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'namaLengkap': namaLengkap,
      'nik': nik,
      'email': email,
      'alamat': alamat,
      'nomorTelepon': nomorTelepon,
      'username': username,
      'password': password,
    };
  }

  // Convert Map to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      namaLengkap: json['namaLengkap'],
      nik: json['nik'],
      email: json['email'],
      alamat: json['alamat'],
      nomorTelepon: json['nomorTelepon'],
      username: json['username'],
      password: json['password'],
    );
  }
}