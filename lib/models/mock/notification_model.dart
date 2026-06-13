class NotificationModel {
  final int? id;
  final int userId;
  final String title;
  final String content;
  final String type; // booking_request, rent_reminder, contract_expiry, payment_success
  final String createdAt; // Định dạng YYYY-MM-DD HH:MM:SS
  final int isRead; // 0: chưa đọc, 1: đã đọc theo cấu trúc INTEGER của SQLite

  NotificationModel({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    this.isRead = 0,
  });

  // Khớp chính xác với các cột trong bảng notifications của SQLite
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      content: map['content'] as String,
      type: map['type'] as String,
      createdAt: map['created_at'] as String,
      isRead: map['is_read'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'type': type,
      'created_at': createdAt,
      'is_read': isRead,
    };
  }
}