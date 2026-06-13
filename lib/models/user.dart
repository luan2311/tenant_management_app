import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid; // Firebase UID (thay vì int id)
  final String fullName;
  final String? phone;
  final String? email;
  final String role; // 'admin' or 'tenant'
  final DateTime? createdAt;
  final String provider; // 'email' or 'google'

  UserModel({
    required this.uid,
    required this.fullName,
    this.phone,
    this.email,
    required this.role,
    this.createdAt,
    this.provider = 'email',
  });

  /// Tạo từ Firestore document snapshot.
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      fullName: data['fullName'] as String? ?? '',
      phone: data['phone'] as String?,
      email: data['email'] as String?,
      role: data['role'] as String? ?? 'tenant',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      provider: data['provider'] as String? ?? 'email',
    );
  }

  /// Tạo từ Map (dùng cho Firestore data trực tiếp).
  factory UserModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return UserModel(
      uid: id ?? map['uid'] as String? ?? '',
      fullName: map['fullName'] as String? ?? map['full_name'] as String? ?? '',
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      role: map['role'] as String? ?? 'tenant',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      provider: map['provider'] as String? ?? 'email',
    );
  }

  /// Chuyển thành Map để ghi vào Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'role': role,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'provider': provider,
    };
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? phone,
    String? email,
    String? role,
    DateTime? createdAt,
    String? provider,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      provider: provider ?? this.provider,
    );
  }
}
