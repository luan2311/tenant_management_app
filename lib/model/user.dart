class UserModel {
  final int? id;
  final String username;
  final String password;
  final String fullName;
  final String? phone;
  final String? email;
  final String role; // 'admin' or 'tenant'
  final int isLoggedIn; // 0 or 1

  UserModel({
    this.id,
    required this.username,
    required this.password,
    required this.fullName,
    this.phone,
    this.email,
    required this.role,
    this.isLoggedIn = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
      fullName: map['full_name'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      role: map['role'] as String,
      isLoggedIn: map['is_logged_in'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'role': role,
      'is_logged_in': isLoggedIn,
    };
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? password,
    String? fullName,
    String? phone,
    String? email,
    String? role,
    int? isLoggedIn,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}
