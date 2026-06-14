class NotificationModel {
  final int? id;
  final int? userId;
  final int? facilityId;
  final String title;
  final String content;
  final String type; // 'booking_request', 'rent_reminder', 'contract_expiry', 'payment_success', 'facility_notice'
  final String createdAt; // YYYY-MM-DD HH:MM:SS
  final int isRead; // 0 or 1

  NotificationModel({
    this.id,
    this.userId,
    this.facilityId,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    this.isRead = 0,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      facilityId: map['facility_id'] as int?,
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
      'facility_id': facilityId,
      'title': title,
      'content': content,
      'type': type,
      'created_at': createdAt,
      'is_read': isRead,
    };
  }

  NotificationModel copyWith({
    int? id,
    int? userId,
    int? facilityId,
    String? title,
    String? content,
    String? type,
    String? createdAt,
    int? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      facilityId: facilityId ?? this.facilityId,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
