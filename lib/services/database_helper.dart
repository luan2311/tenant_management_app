import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tenant_management_app/models/user.dart';
import 'package:tenant_management_app/models/facility.dart';
import 'package:tenant_management_app/models/room.dart';
import 'package:tenant_management_app/models/tenant.dart';
import 'package:tenant_management_app/models/contract.dart';
import 'package:tenant_management_app/models/invoice.dart';
import 'package:tenant_management_app/models/notification.dart';
import 'package:tenant_management_app/models/rental_request.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // Default premium room images to assign to rooms
  static const List<String> defaultRoomImages = [
    'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1484154218962-a197022b5858?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&w=600&q=80',
  ];

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lumiere_stay.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 8,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS rental_requests');
        await db.execute('DROP TABLE IF EXISTS notifications');
        await db.execute('DROP TABLE IF EXISTS invoices');
        await db.execute('DROP TABLE IF EXISTS contracts');
        await db.execute('DROP TABLE IF EXISTS tenants');
        await db.execute('DROP TABLE IF EXISTS rooms');
        await db.execute('DROP TABLE IF EXISTS facilities');
        await db.execute('DROP TABLE IF EXISTS users');
        await _createDB(db, newVersion);
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Users table
    await db.execute('''
      CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          firebase_uid TEXT UNIQUE,
          username TEXT UNIQUE NOT NULL,
          password TEXT NOT NULL,
          full_name TEXT NOT NULL,
          phone TEXT,
          email TEXT,
          role TEXT CHECK(role IN ('admin', 'tenant')) NOT NULL,
          is_logged_in INTEGER DEFAULT 0
      )
    ''');

    // 2. Facilities table
    await db.execute('''
      CREATE TABLE facilities (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          address TEXT NOT NULL,
          status INTEGER DEFAULT 1
      )
    ''');

    // 3. Rooms table
    await db.execute('''
      CREATE TABLE rooms (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          facility_id INTEGER,
          room_number TEXT NOT NULL,
          price REAL NOT NULL,
          deposit REAL NOT NULL,
          max_tenants INTEGER DEFAULT 2,
          status TEXT CHECK(status IN ('empty', 'rented', 'maintenance')) DEFAULT 'empty',
          description TEXT DEFAULT '',
          image_url TEXT,
          amenities TEXT,
          FOREIGN KEY(facility_id) REFERENCES facilities(id) ON DELETE CASCADE
      )
    ''');

    // 4. Tenants table
    await db.execute('''
      CREATE TABLE tenants (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NULL,
          full_name TEXT NOT NULL,
          phone TEXT NOT NULL,
          cccd TEXT UNIQUE NOT NULL,
          hometown TEXT,
          start_date TEXT,
          FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE SET NULL
      )
    ''');

    // 5. Contracts table
    await db.execute('''
      CREATE TABLE contracts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          room_id INTEGER,
          tenant_id INTEGER,
          start_date TEXT NOT NULL,
          end_date TEXT NOT NULL,
          deposit REAL NOT NULL,
          initial_electricity REAL NOT NULL DEFAULT 0,
          initial_water REAL NOT NULL DEFAULT 0,
          status TEXT CHECK(status IN ('active', 'expired', 'terminated')) DEFAULT 'active',
          FOREIGN KEY(room_id) REFERENCES rooms(id) ON DELETE CASCADE,
          FOREIGN KEY(tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
      )
    ''');

    // 6. Invoices table
    await db.execute('''
      CREATE TABLE invoices (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          firestore_id TEXT,
          room_id INTEGER,
          contract_id INTEGER,
          billing_month TEXT NOT NULL,
          old_electricity REAL NOT NULL,
          new_electricity REAL NOT NULL,
          old_water REAL NOT NULL,
          new_water REAL NOT NULL,
          electricity_price REAL NOT NULL,
          water_price REAL NOT NULL,
          service_price REAL DEFAULT 0,
          other_price REAL DEFAULT 0,
          total_price REAL NOT NULL,
          status TEXT CHECK(status IN ('paid', 'unpaid')) DEFAULT 'unpaid',
          payment_date TEXT,
          FOREIGN KEY(room_id) REFERENCES rooms(id) ON DELETE CASCADE,
          FOREIGN KEY(contract_id) REFERENCES contracts(id) ON DELETE CASCADE
      )
    ''');

    // 7. Notifications table
    await db.execute('''
      CREATE TABLE notifications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          type TEXT CHECK(type IN ('booking_request', 'rent_reminder', 'contract_expiry', 'payment_success')) NOT NULL,
          created_at TEXT NOT NULL,
          is_read INTEGER DEFAULT 0,
          FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // 8. Rental Requests table
    await db.execute('''
      CREATE TABLE rental_requests (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          firestore_id TEXT UNIQUE,
          room_id INTEGER NOT NULL,
          room_number TEXT NOT NULL,
          user_uid TEXT NOT NULL,
          full_name TEXT NOT NULL,
          phone TEXT NOT NULL,
          cccd TEXT NOT NULL,
          hometown TEXT,
          start_date TEXT NOT NULL,
          occupants INTEGER DEFAULT 1,
          status TEXT CHECK(status IN ('pending', 'approved', 'rejected')) DEFAULT 'pending',
          created_at TEXT NOT NULL,
          FOREIGN KEY(room_id) REFERENCES rooms(id) ON DELETE CASCADE
      )
    ''');

    // Seed default data
    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    // Seed users
    int adminId = await db.insert('users', {
      'username': 'admin',
      'password': 'admin123', // In a production app, we would hash this
      'full_name': 'Phạm Nguyễn Minh Luân',
      'phone': '0901234567',
      'email': 'luan.admin@lumiere.com',
      'role': 'admin',
      'is_logged_in': 0,
    });

    int tenantId1 = await db.insert('users', {
      'username': 'huytenant',
      'password': 'tenant123',
      'full_name': 'Phùng Tuấn Huy',
      'phone': '0907654321',
      'email': 'huy.tenant@lumiere.com',
      'role': 'tenant',
      'is_logged_in': 0,
    });

    int tenantId2 = await db.insert('users', {
      'username': 'khanhtenant',
      'password': 'tenant123',
      'full_name': 'Phạm Gia Khánh',
      'phone': '0911223344',
      'email': 'khanh.tenant@lumiere.com',
      'role': 'tenant',
      'is_logged_in': 0,
    });

    // Seed facilities
    int fac1 = await db.insert('facilities', {
      'name': 'Lumiere Stay - Cơ sở Quận 1',
      'address': '123 Nguyễn Thị Minh Khai, Bến Thành, Quận 1, TP. HCM',
      'status': 1,
    });

    int fac2 = await db.insert('facilities', {
      'name': 'Lumiere Stay - Cơ sở Quận 3',
      'address': '456 Lê Văn Sỹ, Phường 14, Quận 3, TP. HCM',
      'status': 1,
    });

    final Map<String, int> facilityIds = {'Quan 1': fac1, 'Quan 3': fac2};

    bool seededFromJson = false;

    try {
      final jsonString = await rootBundle.loadString(
        'docs/data/batdongsan_hcm_rooms_sample.json',
      );
      final data = json.decode(jsonString);
      final listings = data['listings'] as List<dynamic>;

      // Track room count per district for generating room numbers
      final Map<String, int> roomCounts = {'Quan 1': 101, 'Quan 3': 201};

      int getStartingRoomNumber(String district) {
        switch (district) {
          case 'Quan 1':
            return 101;
          case 'Quan 3':
            return 201;
          case 'Quan 5':
            return 501;
          case 'Quan 7':
            return 701;
          case 'Quan 9':
            return 901;
          case 'Quan 10':
            return 1001;
          case 'Binh Thanh':
            return 801;
          case 'Tan Binh':
            return 1101;
          case 'Tan Phu':
            return 1201;
          case 'Go Vap':
            return 601;
          case 'TP Thu Duc':
          case 'Thu Duc':
            return 1301;
          default:
            return 1401;
        }
      }

      String getDisplayDistrictName(String district) {
        if (district == 'Binh Thanh') return 'Bình Thạnh';
        if (district == 'Tan Binh') return 'Tân Bình';
        if (district == 'Tan Phu') return 'Tân Phú';
        if (district == 'Go Vap') return 'Gò Vấp';
        if (district == 'TP Thu Duc' || district == 'Thu Duc') return 'Thủ Đức';
        if (district.startsWith('Quan ')) {
          return district.replaceFirst('Quan ', 'Quận ');
        }
        return district;
      }

      for (var listing in listings) {
        final district = listing['district'] as String? ?? 'Quan 1';
        final title = listing['title'] as String;
        final price = (listing['price_vnd'] as num).toDouble();
        final area = (listing['area_m2'] as num).toDouble();
        final amenities = List<String>.from(listing['amenities'] ?? []);

        // Get or create facility for the district
        int facilityId;
        if (facilityIds.containsKey(district)) {
          facilityId = facilityIds[district]!;
        } else {
          final displayName = getDisplayDistrictName(district);
          facilityId = await db.insert('facilities', {
            'name': 'Lumiere Stay - Cơ sở $displayName',
            'address': 'Đường trung tâm, $displayName, TP. HCM',
            'status': 1,
          });
          facilityIds[district] = facilityId;
        }

        // Generate room number
        final startNum = getStartingRoomNumber(district);
        int currentCount = roomCounts[district] ?? startNum;
        final roomNumber = '$currentCount';
        roomCounts[district] = currentCount + 1;

        String status = 'empty';
        if (roomNumber == '101' && district == 'Quan 1') {
          status = 'rented';
        } else if (roomNumber == '201' && district == 'Quan 3') {
          status = 'rented';
        } else if (roomNumber == '202' && district == 'Quan 3') {
          status = 'maintenance';
        }

        int roomId = await db.insert('rooms', {
          'facility_id': facilityId,
          'room_number': roomNumber,
          'price': price,
          'deposit': price * 2,
          'max_tenants': (district == 'Quan 1') ? 2 : 3,
          'status': status,
          'description': 'Diện tích: ${area}m². $title',
          'image_url': defaultRoomImages[(int.tryParse(roomNumber) ?? 0) % defaultRoomImages.length],
          'amenities': json.encode(amenities),
        });

        if (roomNumber == '101' && district == 'Quan 1') {
          int t1 = await db.insert('tenants', {
            'user_id': tenantId1,
            'full_name': 'Phùng Tuấn Huy',
            'phone': '0907654321',
            'cccd': '079123456789',
            'hometown': 'Đà Nẵng',
            'start_date': '2026-01-10',
          });
          int c1 = await db.insert('contracts', {
            'room_id': roomId,
            'tenant_id': t1,
            'start_date': '2026-01-10',
            'end_date': '2027-01-10',
            'deposit': price * 2,
            'initial_electricity': 1200.0,
            'initial_water': 85.0,
            'status': 'active',
          });
          await db.insert('invoices', {
            'room_id': roomId,
            'contract_id': c1,
            'billing_month': '2026-05',
            'old_electricity': 1200.0,
            'new_electricity': 1350.0,
            'old_water': 85.0,
            'new_water': 95.0,
            'electricity_price': 3500.0,
            'water_price': 15000.0,
            'service_price': 150000.0,
            'other_price': 50000.0,
            'total_price':
                price + (150 * 3.5 * 1000) + (10 * 15 * 1000) + 150000 + 50000,
            'status': 'paid',
            'payment_date': '2026-05-05',
          });
          await db.insert('invoices', {
            'room_id': roomId,
            'contract_id': c1,
            'billing_month': '2026-06',
            'old_electricity': 1350.0,
            'new_electricity': 1510.0,
            'old_water': 95.0,
            'new_water': 107.0,
            'electricity_price': 3500.0,
            'water_price': 15000.0,
            'service_price': 150000.0,
            'other_price': 0.0,
            'total_price':
                price + (160 * 3.5 * 1000) + (12 * 15 * 1000) + 150000,
            'status': 'unpaid',
            'payment_date': null,
          });
        } else if (roomNumber == '201' && district == 'Quan 3') {
          int t2 = await db.insert('tenants', {
            'user_id': tenantId2,
            'full_name': 'Phạm Gia Khánh',
            'phone': '0911223344',
            'cccd': '079987654321',
            'hometown': 'Cần Thơ',
            'start_date': '2026-02-15',
          });
          int c2 = await db.insert('contracts', {
            'room_id': roomId,
            'tenant_id': t2,
            'start_date': '2026-02-15',
            'end_date': '2026-08-15',
            'deposit': price * 2,
            'initial_electricity': 500.0,
            'initial_water': 40.0,
            'status': 'active',
          });
          await db.insert('invoices', {
            'room_id': roomId,
            'contract_id': c2,
            'billing_month': '2026-06',
            'old_electricity': 500.0,
            'new_electricity': 620.0,
            'old_water': 40.0,
            'new_water': 52.0,
            'electricity_price': 3500.0,
            'water_price': 15000.0,
            'service_price': 200000.0,
            'other_price': 10000.0,
            'total_price':
                price + (120 * 3.5 * 1000) + (12 * 15 * 1000) + 200000 + 10000,
            'status': 'unpaid',
            'payment_date': null,
          });
        }
      }
      seededFromJson = true;
    } catch (e) {
      print('Seeding from JSON failed: $e. Using fallback.');
    }

    if (!seededFromJson) {
      // Fallback seed
      int r1 = await db.insert('rooms', {
        'facility_id': fac1,
        'room_number': '101',
        'price': 4500000.0,
        'deposit': 9000000.0,
        'max_tenants': 2,
        'status': 'rented',
        'description': 'Diện tích: 22m². Phòng thoáng mát trung tâm Quận 1.',
        'image_url': defaultRoomImages[0],
        'amenities': json.encode([
          'Điều hoà',
          'WC riêng',
          'Wifi',
          'Bãi xe',
          'Tủ lạnh',
        ]),
      });

      await db.insert('rooms', {
        'facility_id': fac1,
        'room_number': '102',
        'price': 4800000.0,
        'deposit': 9600000.0,
        'max_tenants': 2,
        'status': 'empty',
        'description': 'Diện tích: 30m². Căn hộ mini có ban công gần Quận 1.',
        'image_url': defaultRoomImages[1],
        'amenities': json.encode([
          'Điều hoà',
          'WC riêng',
          'Wifi',
          'Bãi xe',
          'Tủ lạnh',
          'Ban công',
        ]),
      });

      int r3 = await db.insert('rooms', {
        'facility_id': fac2,
        'room_number': '201',
        'price': 5200000.0,
        'deposit': 10000000.0,
        'max_tenants': 3,
        'status': 'rented',
        'description': 'Diện tích: 25m². Phòng studio trung tâm Quận 3.',
        'image_url': defaultRoomImages[2],
        'amenities': json.encode([
          'Điều hoà',
          'WC riêng',
          'Wifi',
          'Bãi xe',
          'Ban công',
        ]),
      });

      await db.insert('rooms', {
        'facility_id': fac2,
        'room_number': '202',
        'price': 5500000.0,
        'deposit': 11000000.0,
        'max_tenants': 3,
        'status': 'maintenance',
        'description': 'Diện tích: 20m². Phòng yên tĩnh gần Lê Văn Sỹ Quận 3.',
        'image_url': defaultRoomImages[3],
        'amenities': json.encode(['Điều hoà', 'WC riêng', 'Wifi']),
      });

      int t1 = await db.insert('tenants', {
        'user_id': tenantId1,
        'full_name': 'Phùng Tuấn Huy',
        'phone': '0907654321',
        'cccd': '079123456789',
        'hometown': 'Đà Nẵng',
        'start_date': '2026-01-10',
      });

      int t2 = await db.insert('tenants', {
        'user_id': tenantId2,
        'full_name': 'Phạm Gia Khánh',
        'phone': '0911223344',
        'cccd': '079987654321',
        'hometown': 'Cần Thơ',
        'start_date': '2026-02-15',
      });

      int c1 = await db.insert('contracts', {
        'room_id': r1,
        'tenant_id': t1,
        'start_date': '2026-01-10',
        'end_date': '2027-01-10',
        'deposit': 9000000.0,
        'initial_electricity': 1200.0,
        'initial_water': 85.0,
        'status': 'active',
      });

      int c2 = await db.insert('contracts', {
        'room_id': r3,
        'tenant_id': t2,
        'start_date': '2026-02-15',
        'end_date': '2026-08-15',
        'deposit': 10000000.0,
        'initial_electricity': 500.0,
        'initial_water': 40.0,
        'status': 'active',
      });

      await db.insert('invoices', {
        'room_id': r1,
        'contract_id': c1,
        'billing_month': '2026-05',
        'old_electricity': 1200.0,
        'new_electricity': 1350.0,
        'old_water': 85.0,
        'new_water': 95.0,
        'electricity_price': 3500.0,
        'water_price': 15000.0,
        'service_price': 150000.0,
        'other_price': 50000.0,
        'total_price': 5375000.0,
        'status': 'paid',
        'payment_date': '2026-05-05',
      });

      await db.insert('invoices', {
        'room_id': r1,
        'contract_id': c1,
        'billing_month': '2026-06',
        'old_electricity': 1350.0,
        'new_electricity': 1510.0,
        'old_water': 95.0,
        'new_water': 107.0,
        'electricity_price': 3500.0,
        'water_price': 15000.0,
        'service_price': 150000.0,
        'other_price': 0.0,
        'total_price': 5390000.0,
        'status': 'unpaid',
        'payment_date': null,
      });

      await db.insert('invoices', {
        'room_id': r3,
        'contract_id': c2,
        'billing_month': '2026-06',
        'old_electricity': 500.0,
        'new_electricity': 620.0,
        'old_water': 40.0,
        'new_water': 52.0,
        'electricity_price': 3500.0,
        'water_price': 15000.0,
        'service_price': 200000.0,
        'other_price': 10000.0,
        'total_price': 6010000.0,
        'status': 'unpaid',
        'payment_date': null,
      });
    }

    // Seed notifications
    await db.insert('notifications', {
      'user_id': adminId,
      'title': 'Yêu cầu đặt phòng mới',
      'content':
          'Khách hàng Phùng Tuấn Huy đã gửi yêu cầu thuê phòng 101 tại Cơ sở Quận 1.',
      'type': 'booking_request',
      'created_at': '2026-01-09 10:30:00',
      'is_read': 1,
    });

    await db.insert('notifications', {
      'user_id': tenantId1,
      'title': 'Hóa đơn tiền phòng tháng 06/2026',
      'content':
          'Hóa đơn tiền phòng tháng 06/2026 của bạn đã được khởi tạo. Vui lòng thanh toán trước ngày 05/06/2026.',
      'type': 'rent_reminder',
      'created_at': '2026-06-01 08:00:00',
      'is_read': 0,
    });
  }

  /// Kiểm tra bảng rooms có trống không, nếu trống thì seed từ JSON.
  /// An toàn khi gọi nhiều lần — bỏ qua nếu đã có dữ liệu.
  Future<void> checkAndSeedDatabase() async {
    final db = await database;

    final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM rooms'),
        ) ??
        0;
    if (count > 0) return;

    // Lấy hoặc tạo facility mặc định
    Future<int> getOrCreate(String name, String address) async {
      final rows = await db.query('facilities', columns: ['id'], where: 'name = ?', whereArgs: [name]);
      if (rows.isNotEmpty) return rows.first['id'] as int;
      return db.insert('facilities', {'name': name, 'address': address, 'status': 1});
    }

    final Map<String, int> facilityIds = {
      'Quan 1': await getOrCreate(
        'Lumiere Stay - Cơ sở Quận 1',
        '123 Nguyễn Thị Minh Khai, Bến Thành, Quận 1, TP. HCM',
      ),
      'Quan 3': await getOrCreate(
        'Lumiere Stay - Cơ sở Quận 3',
        '456 Lê Văn Sỹ, Phường 14, Quận 3, TP. HCM',
      ),
    };

    bool seeded = false;
    try {
      final jsonString = await rootBundle.loadString('docs/data/batdongsan_hcm_rooms_sample.json');
      final data = json.decode(jsonString);
      final listings = data['listings'] as List<dynamic>;

      final Map<String, int> roomCounts = {'Quan 1': 101, 'Quan 3': 201};

      int _startNum(String d) {
        switch (d) {
          case 'Quan 1': return 101;
          case 'Quan 3': return 201;
          case 'Quan 5': return 501;
          case 'Quan 7': return 701;
          case 'Quan 9': return 901;
          case 'Quan 10': return 1001;
          case 'Binh Thanh': return 801;
          case 'Tan Binh': return 1101;
          case 'Tan Phu': return 1201;
          case 'Go Vap': return 601;
          case 'TP Thu Duc': case 'Thu Duc': return 1301;
          default: return 1401;
        }
      }

      String _displayDistrict(String d) {
        if (d == 'Binh Thanh') return 'Bình Thạnh';
        if (d == 'Tan Binh') return 'Tân Bình';
        if (d == 'Tan Phu') return 'Tân Phú';
        if (d == 'Go Vap') return 'Gò Vấp';
        if (d == 'TP Thu Duc' || d == 'Thu Duc') return 'Thủ Đức';
        if (d.startsWith('Quan ')) return d.replaceFirst('Quan ', 'Quận ');
        return d;
      }

      for (var listing in listings) {
        final district = listing['district'] as String? ?? 'Quan 1';
        final title = listing['title'] as String;
        final price = (listing['price_vnd'] as num).toDouble();
        final area = (listing['area_m2'] as num).toDouble();
        final amenities = List<String>.from(listing['amenities'] ?? []);

        int facilityId;
        if (facilityIds.containsKey(district)) {
          facilityId = facilityIds[district]!;
        } else {
          final displayName = _displayDistrict(district);
          facilityId = await getOrCreate(
            'Lumiere Stay - Cơ sở $displayName',
            'Đường trung tâm, $displayName, TP. HCM',
          );
          facilityIds[district] = facilityId;
        }

        final startNum = _startNum(district);
        final currentCount = roomCounts[district] ?? startNum;
        final roomNumber = '$currentCount';
        roomCounts[district] = currentCount + 1;

        String status = 'empty';
        if (roomNumber == '101' && district == 'Quan 1') status = 'rented';
        else if (roomNumber == '201' && district == 'Quan 3') status = 'rented';
        else if (roomNumber == '202' && district == 'Quan 3') status = 'maintenance';

        await db.insert('rooms', {
          'facility_id': facilityId,
          'room_number': roomNumber,
          'price': price,
          'deposit': price * 2,
          'max_tenants': (district == 'Quan 1') ? 2 : 3,
          'status': status,
          'description': 'Diện tích: ${area}m². $title',
          'image_url': defaultRoomImages[(int.tryParse(roomNumber) ?? 0) % defaultRoomImages.length],
          'amenities': json.encode(amenities),
        });
      }
      seeded = true;
    } catch (e) {
      print('checkAndSeedDatabase: JSON load failed: $e. Using fallback.');
    }

    if (!seeded) {
      final fac1 = facilityIds['Quan 1']!;
      final fac2 = facilityIds['Quan 3']!;
      await db.insert('rooms', {
        'facility_id': fac1, 'room_number': '101', 'price': 4500000.0,
        'deposit': 9000000.0, 'max_tenants': 2, 'status': 'rented',
        'description': 'Diện tích: 22m². Phòng thoáng mát trung tâm Quận 1.',
        'image_url': defaultRoomImages[0],
        'amenities': json.encode(['Điều hoà', 'WC riêng', 'Wifi', 'Bãi xe', 'Tủ lạnh']),
      });
      await db.insert('rooms', {
        'facility_id': fac1, 'room_number': '102', 'price': 4800000.0,
        'deposit': 9600000.0, 'max_tenants': 2, 'status': 'empty',
        'description': 'Diện tích: 30m². Căn hộ mini có ban công gần Quận 1.',
        'image_url': defaultRoomImages[1],
        'amenities': json.encode(['Điều hoà', 'WC riêng', 'Wifi', 'Bãi xe', 'Tủ lạnh', 'Ban công']),
      });
      await db.insert('rooms', {
        'facility_id': fac2, 'room_number': '201', 'price': 5200000.0,
        'deposit': 10000000.0, 'max_tenants': 3, 'status': 'rented',
        'description': 'Diện tích: 25m². Phòng studio trung tâm Quận 3.',
        'image_url': defaultRoomImages[2],
        'amenities': json.encode(['Điều hoà', 'WC riêng', 'Wifi', 'Bãi xe', 'Ban công']),
      });
      await db.insert('rooms', {
        'facility_id': fac2, 'room_number': '202', 'price': 5500000.0,
        'deposit': 11000000.0, 'max_tenants': 3, 'status': 'maintenance',
        'description': 'Diện tích: 20m². Phòng yên tĩnh gần Lê Văn Sỹ Quận 3.',
        'image_url': defaultRoomImages[3],
        'amenities': json.encode(['Điều hoà', 'WC riêng', 'Wifi']),
      });
    }
  }

  // --- Users CRUD ---
  Future<UserModel?> login(String username, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      // Set as logged in
      await db.update(
        'users',
        {'is_logged_in': 1},
        where: 'id = ?',
        whereArgs: [maps.first['id']],
      );
      return UserModel.fromMap(maps.first, id: maps.first['id']?.toString());
    }
    return null;
  }

  Future<void> logout(int userId) async {
    final db = await instance.database;
    await db.update(
      'users',
      {'is_logged_in': 0},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<UserModel?> getLoggedInUser() async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'is_logged_in = 1', limit: 1);
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first, id: maps.first['id']?.toString());
    }
    return null;
  }

  Future<int> insertUser(UserModel user) async {
    final db = await instance.database;
    return await db.insert('users', {
      'username': user.email?.split('@').first ?? '',
      'password': '',
      'full_name': user.fullName,
      'phone': user.phone,
      'email': user.email,
      'role': user.role,
      'is_logged_in': 0,
    });
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty)
      return UserModel.fromMap(maps.first, id: id.toString());
    return null;
  }

  Future<int> updateUserPassword(int userId, String newPassword) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<bool> verifyUserPassword(int userId, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      columns: ['id'],
      where: 'id = ? AND password = ?',
      whereArgs: [userId, password],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  // --- Facilities CRUD ---
  Future<List<FacilityModel>> getAllFacilities() async {
    final db = await instance.database;
    final maps = await db.query('facilities');
    return maps.map((m) => FacilityModel.fromMap(m)).toList();
  }

  Future<int> insertFacility(FacilityModel facility) async {
    final db = await instance.database;
    return await db.insert('facilities', facility.toMap());
  }

  // --- Rooms CRUD & Custom Queries ---
  Future<List<RoomModel>> getAllRooms() async {
    final db = await instance.database;
    final maps = await db.query('rooms');
    return maps.map((m) => RoomModel.fromMap(m)).toList();
  }

  Future<List<RoomModel>> getRoomsByFacility(int facilityId) async {
    final db = await instance.database;
    final maps = await db.query(
      'rooms',
      where: 'facility_id = ?',
      whereArgs: [facilityId],
    );
    return maps.map((m) => RoomModel.fromMap(m)).toList();
  }

  Future<int> insertRoom(RoomModel room) async {
    final db = await instance.database;
    final map = room.toMap();
    if (map['image_url'] == null || (map['image_url'] as String).isEmpty) {
      final random = DateTime.now().millisecondsSinceEpoch;
      map['image_url'] = defaultRoomImages[random % defaultRoomImages.length];
    }
    return await db.insert('rooms', map);
  }

  Future<int> updateRoom(RoomModel room) async {
    if (room.id == null) return 0;

    final db = await instance.database;
    final values = room.toMap()..remove('id');
    return await db.update(
      'rooms',
      values,
      where: 'id = ?',
      whereArgs: [room.id],
    );
  }

  Future<int> deleteRoom(int roomId) async {
    final db = await instance.database;
    return await db.transaction((txn) async {
      final contracts = await txn.query(
        'contracts',
        columns: ['id'],
        where: 'room_id = ?',
        whereArgs: [roomId],
      );
      final contractIds = contracts.map((row) => row['id'] as int).toList();

      if (contractIds.isNotEmpty) {
        final placeholders = List.filled(contractIds.length, '?').join(', ');
        await txn.delete(
          'invoices',
          where: 'contract_id IN ($placeholders)',
          whereArgs: contractIds,
        );
      }

      await txn.delete('invoices', where: 'room_id = ?', whereArgs: [roomId]);
      await txn.delete('contracts', where: 'room_id = ?', whereArgs: [roomId]);
      return await txn.delete('rooms', where: 'id = ?', whereArgs: [roomId]);
    });
  }

  Future<int> updateRoomStatus(int roomId, String status) async {
    final db = await instance.database;
    return await db.update(
      'rooms',
      {'status': status},
      where: 'id = ?',
      whereArgs: [roomId],
    );
  }

  // --- Tenants CRUD & Custom Queries ---
  Future<List<TenantModel>> getAllTenants() async {
    final db = await instance.database;
    final maps = await db.query('tenants');
    return maps.map((m) => TenantModel.fromMap(m)).toList();
  }

  Future<int> insertTenant(TenantModel tenant) async {
    final db = await instance.database;
    return await db.insert('tenants', tenant.toMap());
  }

  // Task LUAN.3.2: Viết logic tìm kiếm khách thuê theo Họ tên hoặc SĐT (không phân biệt dấu tiếng Việt)
  // SQLite LIKE is case-insensitive, but for diacritics we can use a helper or simple LIKE in SQLite
  // We can select all tenants and filter in Dart for diacritics removal, which is robust and works offline.
  Future<List<TenantModel>> searchTenants(String query) async {
    final db = await instance.database;
    if (query.trim().isEmpty) {
      return await getAllTenants();
    }

    // We fetch all and filter in Dart to handle diacritics removal perfectly
    final maps = await db.query('tenants');
    final allTenants = maps.map((m) => TenantModel.fromMap(m)).toList();

    String normalizedQuery = _removeDiacritics(query.toLowerCase());
    return allTenants.where((tenant) {
      String nameNormalized = _removeDiacritics(tenant.fullName.toLowerCase());
      String phoneNormalized = tenant.phone.trim();
      return nameNormalized.contains(normalizedQuery) ||
          phoneNormalized.contains(normalizedQuery);
    }).toList();
  }

  static String _removeDiacritics(String str) {
    const vietnamese = 'aAeEoOuUiIdDyY';
    const vietnameseRegex = [
      'aàáảãạăằắẳẵặâầấẩẫậ',
      'AÀÁẢÃẠĂẰẮẲẴẶÂẦẤẨẪẬ',
      'eèéẻẽẹêềếểễệ',
      'EÈÉẺẼẸÊỀẾỂỄỆ',
      'oòóỏõọôồốổỗộơờớởỡợ',
      'OÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢ',
      'uùúủũụưừứửữự',
      'UÙÚỦŨỤƯỪỨỬỮỰ',
      'iìíỉĩị',
      'IÌÍỈĨỊ',
      'dđ',
      'DĐ',
      'yỳýỷỹỵ',
      'YỲÝỶỸỴ',
    ];

    String result = str;
    for (int i = 0; i < vietnameseRegex.length; i++) {
      final regex = RegExp('[' + vietnameseRegex[i] + ']');
      result = result.replaceAll(regex, vietnamese[i]);
    }
    return result;
  }

  // --- Contracts CRUD ---
  Future<List<ContractModel>> getAllContracts() async {
    final db = await instance.database;
    final maps = await db.query('contracts');
    return maps.map((m) => ContractModel.fromMap(m)).toList();
  }

  Future<ContractModel?> getActiveContractByRoom(int roomId) async {
    final db = await instance.database;
    final maps = await db.query(
      'contracts',
      where: 'room_id = ? AND status = ?',
      whereArgs: [roomId, 'active'],
      orderBy: 'start_date DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ContractModel.fromMap(maps.first);
  }

  Future<int> insertContract(ContractModel contract) async {
    final db = await instance.database;
    // Task KHANH.2.3: Khi hợp đồng được tạo, lập tức chuyển trạng thái phòng tương ứng thành status = 'rented'
    await db.update(
      'rooms',
      {'status': 'rented'},
      where: 'id = ?',
      whereArgs: [contract.roomId],
    );
    return await db.insert('contracts', contract.toMap());
  }

  Future<int> createContractWithRoomSync(ContractModel contract) async {
    final db = await instance.database;
    return await db.transaction((txn) async {
      await txn.update(
        'rooms',
        {'status': 'rented'},
        where: 'id = ?',
        whereArgs: [contract.roomId],
      );
      return await txn.insert('contracts', contract.toMap());
    });
  }

  Future<int> updateContract(ContractModel contract) async {
    if (contract.id == null) return 0;

    final db = await instance.database;
    final values = contract.toMap()..remove('id');
    return await db.update(
      'contracts',
      values,
      where: 'id = ?',
      whereArgs: [contract.id],
    );
  }

  Future<ContractModel?> getContractById(int contractId) async {
    final db = await instance.database;
    final maps = await db.query(
      'contracts',
      where: 'id = ?',
      whereArgs: [contractId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ContractModel.fromMap(maps.first);
  }

  Future<TenantModel?> getTenantById(int tenantId) async {
    final db = await instance.database;
    final maps = await db.query(
      'tenants',
      where: 'id = ?',
      whereArgs: [tenantId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return TenantModel.fromMap(maps.first);
  }

  Future<RoomModel?> getRoomById(int roomId) async {
    final db = await instance.database;
    final maps = await db.query(
      'rooms',
      where: 'id = ?',
      whereArgs: [roomId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return RoomModel.fromMap(maps.first);
  }

  Future<int> terminateContract(int contractId, int roomId) async {
    final db = await instance.database;
    // Task KHANH.3.2: Lập trình tính năng kết thúc hợp đồng (Trả phòng), tự động đưa phòng trọ về trạng thái trống 'empty'
    await db.update(
      'rooms',
      {'status': 'empty'},
      where: 'id = ?',
      whereArgs: [roomId],
    );
    return await db.update(
      'contracts',
      {'status': 'terminated'},
      where: 'id = ?',
      whereArgs: [contractId],
    );
  }

  Future<int> terminateContractWithRoomSync(int contractId, int roomId) async {
    final db = await instance.database;
    return await db.transaction((txn) async {
      await txn.update(
        'rooms',
        {'status': 'empty'},
        where: 'id = ?',
        whereArgs: [roomId],
      );
      return await txn.update(
        'contracts',
        {'status': 'terminated'},
        where: 'id = ?',
        whereArgs: [contractId],
      );
    });
  }

  // --- Invoices CRUD ---
  Future<InvoiceModel?> getInvoiceById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'invoices',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return InvoiceModel.fromMap(maps.first);
  }

  Future<List<InvoiceModel>> getAllInvoices() async {
    final db = await instance.database;
    final maps = await db.query('invoices');
    return maps.map((m) => InvoiceModel.fromMap(m)).toList();
  }

  Future<int> insertInvoice(InvoiceModel invoice) async {
    final db = await instance.database;
    return await db.insert('invoices', invoice.toMap());
  }

  Future<int> updateInvoice(InvoiceModel invoice) async {
    if (invoice.id == null) return 0;

    final db = await instance.database;
    final values = invoice.toMap()..remove('id');
    return await db.update(
      'invoices',
      values,
      where: 'id = ?',
      whereArgs: [invoice.id],
    );
  }

  Future<int> updateInvoiceStatus(
    int invoiceId,
    String status,
    String? paymentDate,
  ) async {
    final db = await instance.database;
    return await db.update(
      'invoices',
      {'status': status, 'payment_date': paymentDate},
      where: 'id = ?',
      whereArgs: [invoiceId],
    );
  }

  // --- Notifications CRUD ---
  Future<List<NotificationModel>> getNotificationsForUser(int userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => NotificationModel.fromMap(m)).toList();
  }

  Future<int> markNotificationAsRead(int id) async {
    final db = await instance.database;
    return await db.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Dashboard / Thống kê Queries (Task LUAN.2.1, Task LUAN.4.2, Task LUAN.5.1) ---

  // Tổng quan phòng cho Admin Dashboard
  Future<Map<String, int>> getRoomStatistics() async {
    final db = await instance.database;

    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM rooms',
    );
    final emptyResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM rooms WHERE status = "empty"',
    );
    final rentedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM rooms WHERE status = "rented"',
    );
    final maintenanceResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM rooms WHERE status = "maintenance"',
    );

    int total = Sqflite.firstIntValue(totalResult) ?? 0;
    int empty = Sqflite.firstIntValue(emptyResult) ?? 0;
    int rented = Sqflite.firstIntValue(rentedResult) ?? 0;
    int maintenance = Sqflite.firstIntValue(maintenanceResult) ?? 0;

    return {
      'total': total,
      'empty': empty,
      'rented': rented,
      'maintenance': maintenance,
    };
  }

  // Số lượng hóa đơn chưa thanh toán (unpaid)
  Future<int> getUnpaidInvoicesCount() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM invoices WHERE status = "unpaid"',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Thống kê doanh thu theo tháng (Task LUAN.5.1)
  // Trả về map: {'YYYY-MM': tổng_tiền_đã_thu}
  Future<Map<String, double>> getRevenueByMonth() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT billing_month, SUM(total_price) as total 
      FROM invoices 
      WHERE status = 'paid'
      GROUP BY billing_month
      ORDER BY billing_month ASC
    ''');

    Map<String, double> revenue = {};
    for (var row in result) {
      String month = row['billing_month'] as String;
      double total = (row['total'] as num).toDouble();
      revenue[month] = total;
    }
    return revenue;
  }

  Future<Map<String, double>> getRevenueSummary({String? billingMonth}) async {
    final db = await instance.database;
    final whereClause = billingMonth == null ? '' : 'AND billing_month = ?';
    final whereArgs = billingMonth == null
        ? <Object?>[]
        : <Object?>[billingMonth];
    final result = await db.rawQuery('''
      SELECT
        COALESCE(SUM(CASE WHEN status = 'paid' THEN total_price ELSE 0 END), 0) as paid_total,
        COALESCE(SUM(CASE WHEN status = 'unpaid' THEN total_price ELSE 0 END), 0) as unpaid_total
      FROM invoices
      WHERE 1 = 1 $whereClause
    ''', whereArgs);

    final row = result.first;
    return {
      'paid': (row['paid_total'] as num? ?? 0).toDouble(),
      'unpaid': (row['unpaid_total'] as num? ?? 0).toDouble(),
    };
  }

  // Danh sách khách nợ tiền phòng (Task LUAN.5.2)
  Future<List<Map<String, dynamic>>> getDebtorList({
    String? billingMonth,
  }) async {
    final db = await instance.database;
    final monthFilter = billingMonth == null ? '' : 'AND i.billing_month = ?';
    final args = billingMonth == null ? <Object?>[] : <Object?>[billingMonth];
    return await db.rawQuery('''
      SELECT 
        i.id as invoice_id,
        i.billing_month,
        i.total_price,
        r.room_number,
        f.name as facility_name,
        t.full_name as tenant_name,
        t.phone as tenant_phone
      FROM invoices i
      JOIN rooms r ON i.room_id = r.id
      JOIN facilities f ON r.facility_id = f.id
      JOIN contracts c ON i.contract_id = c.id
      JOIN tenants t ON c.tenant_id = t.id
      WHERE i.status = 'unpaid'
        $monthFilter
      ORDER BY i.billing_month DESC
    ''', args);
  }

  // Quét và cập nhật trạng thái hợp đồng / tạo thông báo (Task KHANH.5.1)
  Future<Map<String, dynamic>> runOfflineHealthCheck() async {
    final db = await instance.database;
    final checks = <String, bool>{};

    try {
      checks['database_open'] = db.isOpen;
      checks['users_query'] =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM users'),
          ) !=
          null;
      checks['rooms_query'] =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM rooms'),
          ) !=
          null;
      checks['contracts_query'] =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM contracts'),
          ) !=
          null;
      checks['invoices_query'] =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM invoices'),
          ) !=
          null;
      await getRevenueByMonth();
      checks['revenue_query'] = true;
      await getDebtorList();
      checks['debtor_query'] = true;
    } catch (_) {
      checks['offline_scan_error'] = false;
    }

    final passed = checks.values.where((value) => value).length;
    return {
      'passed': passed,
      'total': checks.length,
      'isHealthy': checks.isNotEmpty && checks.values.every((value) => value),
      'checks': checks,
      'checkedAt': DateTime.now().toIso8601String(),
    };
  }

  Future<void> runBackgroundScans(int currentUserId) async {
    final db = await instance.database;
    final today = DateTime.now();
    final todayStr = today.toIso8601String().substring(0, 10);

    // 1. Quét hết hạn hợp đồng: Nếu hợp đồng cách ngày kết thúc dưới 30 ngày
    final activeContracts = await db.query(
      'contracts',
      where: 'status = "active"',
    );
    for (var row in activeContracts) {
      int id = row['id'] as int;
      String endDateStr = row['end_date'] as String;
      int roomId = row['room_id'] as int;
      int tenantId = row['tenant_id'] as int;

      try {
        DateTime endDate = DateTime.parse(endDateStr);
        int difference = endDate.difference(today).inDays;

        if (difference < 0) {
          // Hợp đồng đã quá hạn, cập nhật trạng thái
          await db.update(
            'contracts',
            {'status': 'expired'},
            where: 'id = ?',
            whereArgs: [id],
          );
          // Đưa phòng về trống nếu quá hạn
          await db.update(
            'rooms',
            {'status': 'empty'},
            where: 'id = ?',
            whereArgs: [roomId],
          );
        } else if (difference <= 30) {
          // Gần hết hạn (dưới 30 ngày). Kiểm tra xem đã thông báo chưa
          final existingNotif = await db.query(
            'notifications',
            where:
                'user_id = ? AND type = "contract_expiry" AND content LIKE ?',
            whereArgs: [currentUserId, '%Hợp đồng số #$id%'],
          );

          if (existingNotif.isEmpty) {
            // Lấy thông tin phòng
            final roomResult = await db.query(
              'rooms',
              columns: ['room_number'],
              where: 'id = ?',
              whereArgs: [roomId],
            );
            String roomNum = roomResult.isNotEmpty
                ? roomResult.first['room_number'] as String
                : '';

            await db.insert('notifications', {
              'user_id': currentUserId,
              'title': 'Hợp đồng sắp hết hạn',
              'content':
                  'Hợp đồng số #$id cho phòng $roomNum sẽ hết hạn sau $difference ngày (vào ngày $endDateStr).',
              'type': 'contract_expiry',
              'created_at': DateTime.now()
                  .toIso8601String()
                  .substring(0, 19)
                  .replaceAll('T', ' '),
              'is_read': 0,
            });
          }
        }
      } catch (e) {
        print("Lỗi quét ngày hợp đồng: \$e");
      }
    }

    // 2. Quét nhắc nợ tiền phòng: Nếu ngày hiện tại nằm từ ngày 1 đến ngày 5 đầu tháng và có hóa đơn unpaid
    if (today.day >= 1 && today.day <= 5) {
      final unpaidInvoices = await db.query(
        'invoices',
        where: 'status = "unpaid"',
      );
      for (var row in unpaidInvoices) {
        int id = row['id'] as int;
        String billingMonth = row['billing_month'] as String;
        int roomId = row['room_id'] as int;

        // Tìm user_id của tenant tương ứng
        final contractResult = await db.query(
          'contracts',
          columns: ['tenant_id'],
          where: 'room_id = ? AND status = "active"',
          whereArgs: [roomId],
        );
        if (contractResult.isNotEmpty) {
          int tenantId = contractResult.first['tenant_id'] as int;
          final tenantResult = await db.query(
            'tenants',
            columns: ['user_id', 'full_name'],
            where: 'id = ?',
            whereArgs: [tenantId],
          );
          if (tenantResult.isNotEmpty &&
              tenantResult.first['user_id'] != null) {
            int tenantUserId = tenantResult.first['user_id'] as int;

            // Kiểm tra xem đã thông báo nhắc nợ cho tháng này chưa
            final existingNotif = await db.query(
              'notifications',
              where:
                  'user_id = ? AND type = "rent_reminder" AND content LIKE ?',
              whereArgs: [tenantUserId, '%tháng $billingMonth%'],
            );

            if (existingNotif.isEmpty) {
              await db.insert('notifications', {
                'user_id': tenantUserId,
                'title': 'Nhắc đóng tiền phòng tháng $billingMonth',
                'content':
                    'Hóa đơn tiền phòng tháng $billingMonth chưa được thanh toán. Vui lòng thanh toán trước ngày 05 của tháng.',
                'type': 'rent_reminder',
                'created_at': DateTime.now()
                    .toIso8601String()
                    .substring(0, 19)
                    .replaceAll('T', ' '),
                'is_read': 0,
              });
            }
          }
        }
      }
    }
  }

  // --- Users & Sync Helper methods ---

  Future<void> syncUserToSQLite(UserModel user) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'firebase_uid = ? OR email = ?',
      whereArgs: [user.uid, user.email ?? ''],
    );
    if (maps.isEmpty) {
      await db.insert('users', {
        'firebase_uid': user.uid,
        'username': user.email?.split('@').first ?? '',
        'password': '',
        'full_name': user.fullName,
        'phone': user.phone,
        'email': user.email,
        'role': user.role,
        'is_logged_in': 1,
      });
    } else {
      final id = maps.first['id'] as int;
      await db.update(
        'users',
        {
          'firebase_uid': user.uid,
          'full_name': user.fullName,
          'phone': user.phone ?? maps.first['phone'],
          'email': user.email ?? maps.first['email'],
          'role': user.role,
          'is_logged_in': 1,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<int?> getLocalUserIdByFirebaseUid(String firebaseUid) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      columns: ['id'],
      where: 'firebase_uid = ?',
      whereArgs: [firebaseUid],
    );
    if (maps.isNotEmpty) {
      return maps.first['id'] as int;
    }
    return null;
  }

  // --- Rental Requests CRUD ---

  Future<int> insertRentalRequest(RentalRequestModel request) async {
    final db = await instance.database;
    return await db.insert('rental_requests', request.toMap());
  }

  Future<List<RentalRequestModel>> getAllRentalRequests() async {
    final db = await instance.database;
    final maps = await db.query('rental_requests', orderBy: 'created_at DESC');
    return maps.map((m) => RentalRequestModel.fromMap(m)).toList();
  }

  Future<List<RentalRequestModel>> getPendingRentalRequests() async {
    final db = await instance.database;
    final maps = await db.query('rental_requests', where: 'status = ?', whereArgs: ['pending'], orderBy: 'created_at DESC');
    return maps.map((m) => RentalRequestModel.fromMap(m)).toList();
  }

  /// Locally approves a rental request in SQLite, syncing the tenant profile and contract details.
  Future<void> localApproveRentalRequest({
    required int requestId,
    required String tenantUid,
    required String fullName,
    required String phone,
    required String cccd,
    required String? hometown,
    required String startDate,
    required int roomId,
    required int durationMonths,
    required double initialElectricity,
    required double initialWater,
  }) async {
    final db = await instance.database;

    await db.transaction((txn) async {
      // 1. Get local user ID
      final userMaps = await txn.query('users', columns: ['id'], where: 'firebase_uid = ?', whereArgs: [tenantUid]);
      int? localUserId;
      if (userMaps.isNotEmpty) {
        localUserId = userMaps.first['id'] as int;
      }

      // 2. Insert or update tenant
      int tenantId;
      final tenantMaps = await txn.query('tenants', where: 'cccd = ?', whereArgs: [cccd]);
      if (tenantMaps.isNotEmpty) {
        tenantId = tenantMaps.first['id'] as int;
        await txn.update(
          'tenants',
          {
            'user_id': localUserId,
            'full_name': fullName,
            'phone': phone,
            'hometown': hometown,
            'start_date': startDate,
          },
          where: 'id = ?',
          whereArgs: [tenantId],
        );
      } else {
        tenantId = await txn.insert('tenants', {
          'user_id': localUserId,
          'full_name': fullName,
          'phone': phone,
          'cccd': cccd,
          'hometown': hometown,
          'start_date': startDate,
        });
      }

      // 3. Update room status to rented
      await txn.update(
        'rooms',
        {'status': 'rented'},
        where: 'id = ?',
        whereArgs: [roomId],
      );

      // 4. Calculate end date
      final start = DateTime.parse(startDate);
      final end = DateTime(start.year, start.month + durationMonths, start.day);
      final endDateStr = end.toIso8601String().substring(0, 10);

      // 5. Get room price for deposit
      final roomMaps = await txn.query('rooms', columns: ['price'], where: 'id = ?', whereArgs: [roomId]);
      final double price = roomMaps.isNotEmpty ? (roomMaps.first['price'] as num).toDouble() : 0.0;

      // 6. Create contract
      await txn.insert('contracts', {
        'room_id': roomId,
        'tenant_id': tenantId,
        'start_date': startDate,
        'end_date': endDateStr,
        'deposit': price * 2,
        'initial_electricity': initialElectricity,
        'initial_water': initialWater,
        'status': 'active',
      });

      // 7. Update rental request status to approved
      await txn.update(
        'rental_requests',
        {'status': 'approved'},
        where: 'id = ?',
        whereArgs: [requestId],
      );
    });
  }

  /// Locally rejects a rental request.
  Future<void> localRejectRentalRequest(int requestId) async {
    final db = await instance.database;
    await db.update(
      'rental_requests',
      {'status': 'rejected'},
      where: 'id = ?',
      whereArgs: [requestId],
    );
  }

  /// Resolves the room, active contract, roommates, and invoices for the logged-in tenant.
  Future<Map<String, dynamic>?> getTenantActiveRoomAndContract(String firebaseUid) async {
    final db = await instance.database;

    // 1. Get local user ID
    final userMaps = await db.query(
      'users',
      columns: ['id'],
      where: 'firebase_uid = ?',
      whereArgs: [firebaseUid],
    );
    if (userMaps.isEmpty) return null;
    final localUserId = userMaps.first['id'] as int;

    // 2. Get tenant record
    final tenantMaps = await db.query(
      'tenants',
      where: 'user_id = ?',
      whereArgs: [localUserId],
    );
    if (tenantMaps.isEmpty) return null;
    final tenantId = tenantMaps.first['id'] as int;
    final tenantData = tenantMaps.first;

    // 3. Get active contract
    final contractMaps = await db.query(
      'contracts',
      where: 'tenant_id = ? AND status = ?',
      whereArgs: [tenantId, 'active'],
      limit: 1,
    );
    if (contractMaps.isEmpty) {
      return {
        'tenant': tenantData,
        'contract': null,
        'room': null,
        'roommates': [],
        'invoices': [],
      };
    }
    final contractData = contractMaps.first;
    final roomId = contractData['room_id'] as int;

    // 4. Get room details
    final roomMaps = await db.query(
      'rooms',
      where: 'id = ?',
      whereArgs: [roomId],
    );
    final roomData = roomMaps.isNotEmpty ? roomMaps.first : null;

    // 5. Get roommates (other tenants who have active contracts in the same room)
    final roommatesMaps = await db.rawQuery('''
      SELECT t.* FROM tenants t
      JOIN contracts c ON c.tenant_id = t.id
      WHERE c.room_id = ? AND c.status = 'active' AND t.id != ?
    ''', [roomId, tenantId]);

    // 6. Get invoices for this contract
    final invoiceMaps = await db.query(
      'invoices',
      where: 'contract_id = ?',
      whereArgs: [contractData['id']],
      orderBy: 'billing_month DESC',
    );

    return {
      'tenant': tenantData,
      'contract': contractData,
      'room': roomData,
      'roommates': roommatesMaps,
      'invoices': invoiceMaps,
    };
  }
}

