import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tenant_management_app/models/rental_request.dart';
import 'package:tenant_management_app/models/contract.dart';
import 'package:tenant_management_app/models/tenant.dart';
import 'package:tenant_management_app/models/notification.dart';
import 'package:tenant_management_app/services/database_helper.dart';

class FirestoreSyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Synchronizes Firestore data with the local SQLite database.
  /// This downloads all relevant records from Firestore and updates the local SQLite tables.
  static Future<void> syncAll(String currentFirebaseUid, String role) async {
    try {
      final db = await DatabaseHelper.instance.database;

      // 1. Sync Room Statuses
      final roomStatusSnap = await _firestore.collection('room_statuses').get();
      for (var doc in roomStatusSnap.docs) {
        final roomNumber = doc.id;
        final status = doc.data()['status'] as String;
        await db.update(
          'rooms',
          {'status': status},
          where: 'room_number = ?',
          whereArgs: [roomNumber],
        );
      }

      // 2. Sync Tenants
      final tenantSnap = await _firestore.collection('tenants').get();
      for (var doc in tenantSnap.docs) {
        final data = doc.data();
        final cccd = data['cccd'] as String;
        
        // Find local user ID associated with user_uid
        final userUid = data['user_uid'] as String?;
        int? localUserId;
        if (userUid != null && userUid.isNotEmpty) {
          final userMaps = await db.query('users', columns: ['id'], where: 'firebase_uid = ?', whereArgs: [userUid]);
          if (userMaps.isNotEmpty) {
            localUserId = userMaps.first['id'] as int;
          }
        }

        final localTenantMaps = await db.query('tenants', where: 'cccd = ?', whereArgs: [cccd]);
        if (localTenantMaps.isEmpty) {
          await db.insert('tenants', {
            'user_id': localUserId,
            'full_name': data['full_name'],
            'phone': data['phone'],
            'cccd': cccd,
            'hometown': data['hometown'],
            'start_date': data['start_date'],
          });
        } else {
          await db.update(
            'tenants',
            {
              'user_id': localUserId,
              'full_name': data['full_name'],
              'phone': data['phone'],
              'hometown': data['hometown'],
              'start_date': data['start_date'],
            },
            where: 'cccd = ?',
            whereArgs: [cccd],
          );
        }
      }

      // 3. Sync Contracts
      final contractSnap = await _firestore.collection('contracts').get();
      for (var doc in contractSnap.docs) {
        final data = doc.data();
        final roomNumber = data['room_number'] as String;
        final tenantCccd = data['tenant_cccd'] as String;

        // Find local room_id
        final roomMaps = await db.query('rooms', columns: ['id'], where: 'room_number = ?', whereArgs: [roomNumber]);
        if (roomMaps.isEmpty) continue;
        final roomId = roomMaps.first['id'] as int;

        // Find local tenant_id
        final tenantMaps = await db.query('tenants', columns: ['id'], where: 'cccd = ?', whereArgs: [tenantCccd]);
        if (tenantMaps.isEmpty) continue;
        final tenantId = tenantMaps.first['id'] as int;

        // Check if contract already exists by firestore_id or room_id & tenant_id combination
        final localContractMaps = await db.query(
          'contracts',
          where: 'room_id = ? AND tenant_id = ? AND start_date = ?',
          whereArgs: [roomId, tenantId, data['start_date']],
        );

        if (localContractMaps.isEmpty) {
          await db.insert('contracts', {
            'room_id': roomId,
            'tenant_id': tenantId,
            'start_date': data['start_date'],
            'end_date': data['end_date'],
            'deposit': data['deposit'],
            'initial_electricity': data['initial_electricity'],
            'initial_water': data['initial_water'],
            'status': data['status'],
          });
        } else {
          await db.update(
            'contracts',
            {
              'end_date': data['end_date'],
              'deposit': data['deposit'],
              'initial_electricity': data['initial_electricity'],
              'initial_water': data['initial_water'],
              'status': data['status'],
            },
            where: 'id = ?',
            whereArgs: [localContractMaps.first['id']],
          );
        }
      }

      // 4. Sync Rental Requests
      final requestSnap = await _firestore.collection('rental_requests').get();
      for (var doc in requestSnap.docs) {
        final data = doc.data();
        final roomNumber = data['room_number'] as String;
        final userUid = data['user_uid'] as String;

        // Find local room_id
        final roomMaps = await db.query('rooms', columns: ['id'], where: 'room_number = ?', whereArgs: [roomNumber]);
        if (roomMaps.isEmpty) continue;
        final roomId = roomMaps.first['id'] as int;

        final localRequestMaps = await db.query(
          'rental_requests',
          where: 'room_id = ? AND user_uid = ? AND created_at = ?',
          whereArgs: [roomId, userUid, data['created_at']],
        );

        if (localRequestMaps.isEmpty) {
          await db.insert('rental_requests', {
            'firestore_id': doc.id,
            'room_id': roomId,
            'room_number': roomNumber,
            'user_uid': userUid,
            'full_name': data['full_name'],
            'phone': data['phone'],
            'cccd': data['cccd'],
            'hometown': data['hometown'],
            'start_date': data['start_date'],
            'occupants': data['occupants'],
            'status': data['status'],
            'created_at': data['created_at'],
          });
        } else {
          await db.update(
            'rental_requests',
            {
              'firestore_id': doc.id,
              'status': data['status'],
            },
            where: 'id = ?',
            whereArgs: [localRequestMaps.first['id']],
          );
        }
      }

      // 5. Sync Notifications
      // Pull notifications meant for this user (or admin)
      final userQuery = role == 'admin' ? 'admin' : currentFirebaseUid;
      final notifSnap = await _firestore
          .collection('notifications')
          .where('user_uid', isEqualTo: userQuery)
          .get();

      for (var doc in notifSnap.docs) {
        final data = doc.data();
        
        final localNotifMaps = await db.query(
          'notifications',
          where: 'created_at = ? AND title = ?',
          whereArgs: [data['created_at'], data['title']],
        );

        if (localNotifMaps.isEmpty) {
          await db.insert('notifications', {
            'user_id': currentFirebaseUid.hashCode, // Fallback hashed int for local user_id
            'title': data['title'],
            'content': data['content'],
            'type': data['type'],
            'created_at': data['created_at'],
            'is_read': data['is_read'],
          });
        } else {
          // Sync read status from cloud to local, or local to cloud
          // In this implementation, we can just update the local status to match cloud
          await db.update(
            'notifications',
            {
              'is_read': data['is_read'],
            },
            where: 'id = ?',
            whereArgs: [localNotifMaps.first['id']],
          );
        }
      }

      print("Firestore synchronization completed successfully.");
    } catch (e) {
      print("Error during Firestore sync: $e");
    }
  }

  /// Pushes a rental request to Firestore.
  static Future<String> sendRentalRequest(RentalRequestModel request) async {
    final docRef = await _firestore.collection('rental_requests').add({
      'room_id': request.roomId,
      'room_number': request.roomNumber,
      'user_uid': request.userUid,
      'full_name': request.fullName,
      'phone': request.phone,
      'cccd': request.cccd,
      'hometown': request.hometown,
      'start_date': request.startDate,
      'occupants': request.occupants,
      'status': request.status,
      'created_at': request.createdAt,
    });

    // Send admin notification
    await _firestore.collection('notifications').add({
      'user_uid': 'admin',
      'title': 'Yêu cầu thuê phòng mới',
      'content': 'Khách hàng ${request.fullName} đã gửi yêu cầu thuê phòng ${request.roomNumber}.',
      'type': 'booking_request',
      'created_at': request.createdAt,
      'is_read': 0,
    });

    return docRef.id;
  }

  /// Approves a rental request, updates the request status,
  /// creates the tenant profile, creates the contract, and updates room status in Firestore.
  static Future<void> approveRentalRequest({
    required String firestoreRequestId,
    required String tenantUid,
    required String fullName,
    required String phone,
    required String cccd,
    required String? hometown,
    required String startDate,
    required int roomId,
    required String roomNumber,
    required double roomPrice,
    required int durationMonths,
    required double initialElectricity,
    required double initialWater,
  }) async {
    final batch = _firestore.batch();

    // 1. Update rental request status to 'approved'
    final requestRef = _firestore.collection('rental_requests').doc(firestoreRequestId);
    batch.update(requestRef, {'status': 'approved'});

    // 2. Add or update tenant profile
    final tenantRef = _firestore.collection('tenants').doc(cccd);
    batch.set(tenantRef, {
      'user_uid': tenantUid,
      'full_name': fullName,
      'phone': phone,
      'cccd': cccd,
      'hometown': hometown,
      'start_date': startDate,
    });

    // 3. Calculate lease end date
    final start = DateTime.parse(startDate);
    final end = DateTime(start.year, start.month + durationMonths, start.day);
    final endDateStr = end.toIso8601String().substring(0, 10);

    // 4. Create contract
    final contractRef = _firestore.collection('contracts').doc();
    batch.set(contractRef, {
      'room_id': roomId,
      'room_number': roomNumber,
      'tenant_cccd': cccd,
      'start_date': startDate,
      'end_date': endDateStr,
      'deposit': roomPrice * 2,
      'initial_electricity': initialElectricity,
      'initial_water': initialWater,
      'status': 'active',
    });

    // 5. Update room status to 'rented'
    final roomStatusRef = _firestore.collection('room_statuses').doc(roomNumber);
    batch.set(roomStatusRef, {'status': 'rented'});

    // 6. Create tenant notification
    final notifRef = _firestore.collection('notifications').doc();
    batch.set(notifRef, {
      'user_uid': tenantUid,
      'title': 'Yêu cầu thuê phòng đã được duyệt',
      'content': 'Chúc mừng! Yêu cầu thuê phòng $roomNumber của bạn đã được duyệt. Hợp đồng thuê đã được kích hoạt.',
      'type': 'payment_success',
      'created_at': DateTime.now().toIso8601String().replaceAll('T', ' ').substring(0, 19),
      'is_read': 0,
    });

    await batch.commit();
  }

  /// Rejects a rental request, updates status and sends notification.
  static Future<void> rejectRentalRequest({
    required String firestoreRequestId,
    required String tenantUid,
    required String roomNumber,
  }) async {
    final batch = _firestore.batch();

    // 1. Update rental request status to 'rejected'
    final requestRef = _firestore.collection('rental_requests').doc(firestoreRequestId);
    batch.update(requestRef, {'status': 'rejected'});

    // 2. Create tenant notification
    final notifRef = _firestore.collection('notifications').doc();
    batch.set(notifRef, {
      'user_uid': tenantUid,
      'title': 'Yêu cầu thuê phòng không được duyệt',
      'content': 'Rất tiếc, yêu cầu thuê phòng $roomNumber của bạn đã bị từ chối hoặc phòng không còn trống.',
      'type': 'contract_expiry', // Use contract_expiry type for warnings
      'created_at': DateTime.now().toIso8601String().replaceAll('T', ' ').substring(0, 19),
      'is_read': 0,
    });

    await batch.commit();
  }

  /// Pushes a new roommate (tenant + contract) to Firestore.
  static Future<void> addRoommate({
    required String fullName,
    required String phone,
    required String cccd,
    required String? hometown,
    required String startDate,
    required int roomId,
    required String roomNumber,
    required String endDate,
  }) async {
    final batch = _firestore.batch();
    
    // Add to tenants
    final tenantRef = _firestore.collection('tenants').doc(cccd);
    batch.set(tenantRef, {
      'user_uid': '',
      'full_name': fullName,
      'phone': phone,
      'cccd': cccd,
      'hometown': hometown,
      'start_date': startDate,
    });

    // Add to contracts
    final contractRef = _firestore.collection('contracts').doc();
    batch.set(contractRef, {
      'room_id': roomId,
      'room_number': roomNumber,
      'tenant_cccd': cccd,
      'start_date': startDate,
      'end_date': endDate,
      'deposit': 0.0,
      'initial_electricity': 0.0,
      'initial_water': 0.0,
      'status': 'active',
    });

    await batch.commit();
  }

  /// Terminates roommate active contract on Firestore.
  static Future<void> removeRoommate({
    required String roomNumber,
    required String cccd,
  }) async {
    final querySnap = await _firestore
        .collection('contracts')
        .where('room_number', isEqualTo: roomNumber)
        .where('tenant_cccd', isEqualTo: cccd)
        .where('status', isEqualTo: 'active')
        .get();

    final batch = _firestore.batch();
    for (var doc in querySnap.docs) {
      batch.update(doc.reference, {'status': 'terminated'});
    }
    await batch.commit();
  }

  /// Terminates a contract on Firestore and updates room status to empty.
  static Future<void> terminateContract({
    required String roomNumber,
    required String tenantCccd,
  }) async {
    final batch = _firestore.batch();

    final querySnap = await _firestore
        .collection('contracts')
        .where('room_number', isEqualTo: roomNumber)
        .where('tenant_cccd', isEqualTo: tenantCccd)
        .where('status', isEqualTo: 'active')
        .get();

    for (var doc in querySnap.docs) {
      batch.update(doc.reference, {'status': 'terminated'});
    }

    final roomStatusRef = _firestore.collection('room_statuses').doc(roomNumber);
    batch.set(roomStatusRef, {'status': 'empty'});

    await batch.commit();
  }

  /// Approves contract extension on Firestore and sends a tenant notification.
  static Future<void> approveContractExtension({
    required String roomNumber,
    required String tenantCccd,
    required String newEndDate,
    required String? tenantUid,
  }) async {
    final batch = _firestore.batch();

    final querySnap = await _firestore
        .collection('contracts')
        .where('room_number', isEqualTo: roomNumber)
        .where('tenant_cccd', isEqualTo: tenantCccd)
        .where('status', isEqualTo: 'active')
        .get();

    for (var doc in querySnap.docs) {
      batch.update(doc.reference, {'end_date': newEndDate});
    }

    if (tenantUid != null && tenantUid.isNotEmpty) {
      final notifRef = _firestore.collection('notifications').doc();
      batch.set(notifRef, {
        'user_uid': tenantUid,
        'title': 'Yêu cầu gia hạn hợp đồng đã được duyệt',
        'content': 'Hợp đồng phòng $roomNumber của bạn đã được gia hạn đến ngày $newEndDate.',
        'type': 'payment_success',
        'created_at': DateTime.now().toIso8601String().replaceAll('T', ' ').substring(0, 19),
        'is_read': 0,
      });
    }

    await batch.commit();
  }

  /// Sends a generic notification to Firestore.
  static Future<void> sendNotification({
    required String userUid,
    required String title,
    required String content,
    required String type,
  }) async {
    await _firestore.collection('notifications').add({
      'user_uid': userUid,
      'title': title,
      'content': content,
      'type': type,
      'created_at': DateTime.now().toIso8601String().replaceAll('T', ' ').substring(0, 19),
      'is_read': 0,
    });
  }
}
