import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tenant_management_app/models/user.dart';
import 'package:tenant_management_app/models/facility.dart';
import 'package:tenant_management_app/models/room.dart';
import 'package:tenant_management_app/models/tenant.dart';
import 'package:tenant_management_app/models/contract.dart';
import 'package:tenant_management_app/models/invoice.dart';
import 'package:tenant_management_app/models/notification.dart';
import 'package:tenant_management_app/models/rental_request.dart';
import 'package:tenant_management_app/services/firestore_sync_service.dart';
import 'database_helper.dart';
import 'package:tenant_management_app/services/auth_service.dart';

class AppState extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  UserModel? _currentUser;
  List<FacilityModel> _facilities = [];
  List<RoomModel> _rooms = [];
  List<TenantModel> _tenants = [];
  List<ContractModel> _contracts = [];
  List<InvoiceModel> _invoices = [];
  List<NotificationModel> _notifications = [];
  List<RentalRequestModel> _rentalRequests = [];
  Map<String, dynamic>? activeRoomData;

  // Filtered lists for Admin UI
  List<RoomModel> _filteredRooms = [];
  List<TenantModel> _filteredTenants = [];

  // Current selections for filtering (Sprint 3)
  int? selectedFacilityId;
  String selectedRoomStatus = 'all'; // 'all', 'empty', 'rented', 'maintenance'
  String tenantSearchQuery = '';

  // Stats
  Map<String, int> roomStats = {
    'total': 0,
    'empty': 0,
    'rented': 0,
    'maintenance': 0,
  };
  int unpaidInvoicesCount = 0;
  Map<String, double> monthlyRevenue = {};
  Map<String, double> revenueSummary = {'paid': 0, 'unpaid': 0};
  List<Map<String, dynamic>> debtorList = [];
  Map<String, dynamic>? offlineHealthCheck;

  bool _isLoading = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  List<FacilityModel> get facilities => _facilities;
  List<RoomModel> get rooms => _rooms;
  List<RoomModel> get filteredRooms => _filteredRooms;
  List<TenantModel> get tenants => _tenants;
  List<TenantModel> get filteredTenants => _filteredTenants;
  List<ContractModel> get contracts => _contracts;
  List<InvoiceModel> get invoices => _invoices;
  List<NotificationModel> get notifications => _notifications;
  List<RentalRequestModel> get rentalRequests => _rentalRequests;
  List<RentalRequestModel> get pendingRequests =>
      _rentalRequests.where((r) => r.status == 'pending').toList();
  bool get isLoading => _isLoading;
  String get currentBillingMonth => _formatBillingMonth(DateTime.now());

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // --- Auth ---
  Future<bool> login(String email, String password) async {
    setLoading(true);
    try {
      final userModel = await AuthService.signInWithEmail(email, password);
      if (userModel != null) {
        _currentUser = userModel;
        await refreshAllData();
        setLoading(false);
        return true;
      }
    } catch (_) {
      // Lỗi xác thực sẽ được xử lý ở UI layer
    }
    setLoading(false);
    return false;
  }

  Future<void> logout() async {
    await AuthService.clearSession();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> checkAutoLogin() async {
    setLoading(true);
    final user = await AuthService.getCurrentUserModel();
    if (user != null) {
      _currentUser = user;
      await refreshAllData();
    }
    setLoading(false);
  }

  /// Đặt user đã đăng nhập từ Firebase (dùng cho AdminLoginScreen).
  Future<void> loginWithFirebaseUser(UserModel user) async {
    _currentUser = user;
    await refreshAllData();
    notifyListeners();
  }

  // --- Data Loading & Synchronization ---
  Future<void> refreshAllData() async {
    if (_currentUser == null) return;

    // Đảm bảo bảng rooms luôn có dữ liệu mẫu (an toàn khi gọi nhiều lần)
    await _db.checkAndSeedDatabase();

    // Sync current user profile from Firebase to local SQLite
    await _db.syncUserToSQLite(_currentUser!);

    // Pull and sync all tables from Cloud Firestore to local SQLite for real-time cross-device sync
    await FirestoreSyncService.syncAll(_currentUser!.uid, _currentUser!.role);

    // Run background scans for notifications/contracts
    // Background scans dùng int id — tạm dùng hashCode từ UID
    await _db.runBackgroundScans(_currentUser!.uid.hashCode);

    _facilities = await _db.getAllFacilities();
    _rooms = await _db.getAllRooms();
    _tenants = await _db.getAllTenants();
    _contracts = await _db.getAllContracts();
    _invoices = await _db.getAllInvoices();
    _notifications = await _db.getNotificationsForUser(
      _currentUser!.uid.hashCode,
    );

    // Fetch rental requests
    _rentalRequests = await _db.getAllRentalRequests();

    // If role is tenant, resolve their active room & contract details from database helper
    if (_currentUser!.role == 'tenant') {
      activeRoomData = await _db.getTenantActiveRoomAndContract(
        _currentUser!.uid,
      );
    } else {
      activeRoomData = null;
    }

    // Load stats
    roomStats = await _db.getRoomStatistics();
    unpaidInvoicesCount = await _db.getUnpaidInvoicesCount();
    monthlyRevenue = await _db.getRevenueByMonth();
    revenueSummary = await _db.getRevenueSummary(
      billingMonth: currentBillingMonth,
    );
    debtorList = await _db.getDebtorList(billingMonth: currentBillingMonth);

    applyFilters();
  }

  // --- Room Operations ---
  Future<bool> addNewRoom(RoomModel room) async {
    setLoading(true);
    final id = await _db.insertRoom(room);
    if (id > 0) {
      await refreshAllData();
      setLoading(false);
      return true;
    }
    setLoading(false);
    return false;
  }

  Future<bool> updateRoom(RoomModel room) async {
    setLoading(true);
    final affectedRows = await _db.updateRoom(room);
    if (affectedRows > 0) {
      await refreshAllData();
      setLoading(false);
      return true;
    }
    setLoading(false);
    return false;
  }

  Future<bool> deleteRoom(int roomId) async {
    setLoading(true);
    final affectedRows = await _db.deleteRoom(roomId);
    if (affectedRows > 0) {
      await refreshAllData();
      setLoading(false);
      return true;
    }
    setLoading(false);
    return false;
  }

  Future<PasswordChangeResult> changeCurrentUserPassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await AuthService.changePassword(currentPassword, newPassword);
      return const PasswordChangeResult.success();
    } on FirebaseAuthException catch (e) {
      return PasswordChangeResult.failure(_passwordChangeErrorMessage(e));
    } catch (_) {
      return const PasswordChangeResult.failure(
        'Không thể đổi mật khẩu. Vui lòng thử lại.',
      );
    }
  }

  String _passwordChangeErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Mật khẩu hiện tại không đúng.';
      case 'weak-password':
        return 'Mật khẩu mới cần ít nhất 6 ký tự.';
      case 'requires-recent-login':
        return 'Phiên đăng nhập đã cũ. Vui lòng đăng xuất rồi đăng nhập lại trước khi đổi mật khẩu.';
      case 'network-request-failed':
        return 'Không có kết nối mạng. Vui lòng kiểm tra internet rồi thử lại.';
      case 'too-many-requests':
        return 'Bạn thao tác quá nhiều lần. Vui lòng chờ một lát rồi thử lại.';
      case 'user-mismatch':
      case 'user-not-found':
      case 'no-user':
        return 'Không tìm thấy phiên đăng nhập hiện tại. Vui lòng đăng nhập lại.';
      default:
        return error.message?.trim().isNotEmpty == true
            ? error.message!.trim()
            : 'Không thể đổi mật khẩu. Vui lòng thử lại.';
    }
  }

  Future<void> runOfflineHealthCheck() async {
    offlineHealthCheck = await _db.runOfflineHealthCheck();
    notifyListeners();
  }

  Future<bool> saveContract(ContractModel contract) async {
    setLoading(true);
    final affectedRows = contract.id == null
        ? await _db.createContractWithRoomSync(contract)
        : await _db.updateContract(contract);
    if (affectedRows > 0) {
      await refreshAllData();
      setLoading(false);
      return true;
    }
    setLoading(false);
    return false;
  }

  Future<bool> terminateContract(int contractId, int roomId) async {
    setLoading(true);
    try {
      final contract = await _db.getContractById(contractId);
      final tenant = contract != null
          ? await _db.getTenantById(contract.tenantId)
          : null;
      final room = await _db.getRoomById(roomId);

      // 1. Sync on Firestore
      if (room != null && tenant != null) {
        await FirestoreSyncService.terminateContract(
          roomNumber: room.roomNumber,
          tenantCccd: tenant.cccd,
        );
      }

      // 2. Local SQLite update
      final affectedRows = await _db.terminateContractWithRoomSync(
        contractId,
        roomId,
      );
      if (affectedRows > 0) {
        await refreshAllData();
        setLoading(false);
        return true;
      }
    } catch (e) {
      print("Error terminating contract: $e");
    }
    setLoading(false);
    return false;
  }

  Future<bool> addRoommate({
    required String fullName,
    required String phone,
    required String cccd,
    required String hometown,
  }) async {
    final activeData = activeRoomData;
    if (activeData == null ||
        activeData['room'] == null ||
        activeData['contract'] == null) {
      return false;
    }
    setLoading(true);
    try {
      final room = activeData['room'];
      final contract = activeData['contract'];
      final roomId = room['id'] as int;
      final roomNumber = room['room_number'] as String;
      final endDate = contract['end_date'] as String;
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);

      // 1. Write to Firestore
      await FirestoreSyncService.addRoommate(
        fullName: fullName,
        phone: phone,
        cccd: cccd,
        hometown: hometown,
        startDate: todayStr,
        roomId: roomId,
        roomNumber: roomNumber,
        endDate: endDate,
      );

      // 2. Insert locally to SQLite
      final localTenantId = await _db.insertTenant(
        TenantModel(
          fullName: fullName,
          phone: phone,
          cccd: cccd,
          hometown: hometown,
          startDate: todayStr,
        ),
      );

      await _db.insertContract(
        ContractModel(
          roomId: roomId,
          tenantId: localTenantId,
          startDate: todayStr,
          endDate: endDate,
          deposit: 0.0,
          status: 'active',
        ),
      );

      await refreshAllData();
      setLoading(false);
      return true;
    } catch (e) {
      print("Error adding roommate: $e");
    }
    setLoading(false);
    return false;
  }

  Future<bool> removeRoommate(String cccd) async {
    final activeData = activeRoomData;
    if (activeData == null || activeData['room'] == null) {
      return false;
    }
    setLoading(true);
    try {
      final room = activeData['room'];
      final roomId = room['id'] as int;
      final roomNumber = room['room_number'] as String;

      // 1. Sync on Firestore
      await FirestoreSyncService.removeRoommate(
        roomNumber: roomNumber,
        cccd: cccd,
      );

      // 2. Update locally in SQLite
      final db = await _db.database;
      final tenantMaps = await db.query(
        'tenants',
        columns: ['id'],
        where: 'cccd = ?',
        whereArgs: [cccd],
      );
      if (tenantMaps.isNotEmpty) {
        final tenantId = tenantMaps.first['id'] as int;
        await db.update(
          'contracts',
          {'status': 'terminated'},
          where: 'room_id = ? AND tenant_id = ? AND status = ?',
          whereArgs: [roomId, tenantId, 'active'],
        );
      }

      await refreshAllData();
      setLoading(false);
      return true;
    } catch (e) {
      print("Error removing roommate: $e");
    }
    setLoading(false);
    return false;
  }

  Future<bool> approveContractExtension(int contractId, int months) async {
    setLoading(true);
    try {
      final contract = await _db.getContractById(contractId);
      if (contract == null) {
        setLoading(false);
        return false;
      }
      final tenant = await _db.getTenantById(contract.tenantId);
      final room = await _db.getRoomById(contract.roomId);

      if (tenant == null || room == null) {
        setLoading(false);
        return false;
      }

      // Calculate new end date
      final currentEnd = DateTime.parse(contract.endDate);
      final newEnd = DateTime(
        currentEnd.year,
        currentEnd.month + months,
        currentEnd.day,
      );
      final newEndDateStr = newEnd.toIso8601String().substring(0, 10);

      // Fetch userUid of tenant to notify them
      String? tenantUid;
      if (tenant.userId != null) {
        final db = await _db.database;
        final userMaps = await db.query(
          'users',
          columns: ['firebase_uid'],
          where: 'id = ?',
          whereArgs: [tenant.userId],
        );
        if (userMaps.isNotEmpty) {
          tenantUid = userMaps.first['firebase_uid'] as String?;
        }
      }

      // Sync to Firestore
      await FirestoreSyncService.approveContractExtension(
        roomNumber: room.roomNumber,
        tenantCccd: tenant.cccd,
        newEndDate: newEndDateStr,
        tenantUid: tenantUid,
      );

      // Update SQLite contract
      final updatedContract = contract.copyWith(endDate: newEndDateStr);
      await _db.updateContract(updatedContract);

      await refreshAllData();
      setLoading(false);
      return true;
    } catch (e) {
      print("Error approving contract extension: $e");
    }
    setLoading(false);
    return false;
  }

  Future<bool> saveInvoice(InvoiceModel invoice) async {
    setLoading(true);
    try {
      final db = await _db.database;
      // Get room number
      final roomMaps = await db.query(
        'rooms',
        columns: ['room_number'],
        where: 'id = ?',
        whereArgs: [invoice.roomId],
      );
      final roomNumber = roomMaps.isNotEmpty
          ? roomMaps.first['room_number'] as String
          : '';

      // Get tenant CCCD
      final contractMaps = await db.query(
        'contracts',
        columns: ['tenant_id'],
        where: 'id = ?',
        whereArgs: [invoice.contractId],
      );
      String tenantCccd = '';
      if (contractMaps.isNotEmpty) {
        final tenantId = contractMaps.first['tenant_id'] as int;
        final tenantMaps = await db.query(
          'tenants',
          columns: ['cccd'],
          where: 'id = ?',
          whereArgs: [tenantId],
        );
        if (tenantMaps.isNotEmpty) {
          tenantCccd = tenantMaps.first['cccd'] as String;
        }
      }

      // Sync to Firestore
      final firestoreId = await FirestoreSyncService.saveInvoice(
        invoice,
        roomNumber: roomNumber,
        tenantCccd: tenantCccd,
      );

      // Save locally with firestoreId
      final invoiceWithFirestore = invoice.copyWith(firestoreId: firestoreId);
      final affectedRows = invoice.id == null
          ? await _db.insertInvoice(invoiceWithFirestore)
          : await _db.updateInvoice(invoiceWithFirestore);

      if (affectedRows > 0) {
        await refreshAllData();
        setLoading(false);
        return true;
      }
    } catch (e) {
      print("Error saving/syncing invoice: $e");
    }
    setLoading(false);
    return false;
  }

  Future<bool> markInvoicePaid(int invoiceId) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    try {
      final localInvoice = await _db.getInvoiceById(invoiceId);
      if (localInvoice != null &&
          localInvoice.firestoreId != null &&
          localInvoice.firestoreId!.isNotEmpty) {
        await FirestoreSyncService.updateInvoiceStatus(
          firestoreId: localInvoice.firestoreId!,
          status: 'paid',
          paymentDate: today,
        );
      }
      final affectedRows = await _db.updateInvoiceStatus(
        invoiceId,
        'paid',
        today,
      );
      if (affectedRows > 0) {
        await refreshAllData();
        return true;
      }
    } catch (e) {
      print("Error marking invoice paid: $e");
    }
    return false;
  }

  // Task LUAN.3.3: Viết logic lọc phòng nhanh theo trạng thái và theo từng Cơ sở trọ trực quan
  void filterRoomsByFacility(int? facilityId) {
    selectedFacilityId = facilityId;
    applyFilters();
  }

  void filterRoomsByStatus(String status) {
    selectedRoomStatus = status;
    applyFilters();
  }

  void applyFilters() {
    // Rooms filter
    _filteredRooms = _rooms.where((room) {
      final matchesFacility =
          selectedFacilityId == null || room.facilityId == selectedFacilityId;
      final matchesStatus =
          selectedRoomStatus == 'all' || room.status == selectedRoomStatus;
      return matchesFacility && matchesStatus;
    }).toList();

    // Tenants filter / search
    if (tenantSearchQuery.trim().isEmpty) {
      _filteredTenants = List.from(_tenants);
    } else {
      String queryLower = _removeDiacritics(tenantSearchQuery.toLowerCase());
      _filteredTenants = _tenants.where((tenant) {
        String nameNormalized = _removeDiacritics(
          tenant.fullName.toLowerCase(),
        );
        String phoneNormalized = tenant.phone.trim();
        return nameNormalized.contains(queryLower) ||
            phoneNormalized.contains(queryLower);
      }).toList();
    }

    notifyListeners();
  }

  // Task LUAN.3.2: Tìm kiếm khách thuê (trigger filtering in memory immediately for fast response)
  void searchTenants(String query) {
    tenantSearchQuery = query;
    applyFilters();
  }

  // --- Notifications Operations ---
  Future<void> readNotification(int notifId) async {
    await _db.markNotificationAsRead(notifId);
    if (_currentUser != null) {
      _notifications = await _db.getNotificationsForUser(
        _currentUser!.uid.hashCode,
      );
      notifyListeners();
    }
  }

  // Helper for Vietnamese diacritics removal
  String _removeDiacritics(String str) {
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

  String _formatBillingMonth(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    return '${value.year}-$month';
  }

  // --- Rental Request Operations ---

  Future<bool> sendRentalRequest(RentalRequestModel request) async {
    setLoading(true);
    try {
      // 1. Send to Firestore & get cloud ID
      final firestoreId = await FirestoreSyncService.sendRentalRequest(request);

      // 2. Insert to local SQLite
      final localRequest = request.copyWith(firestoreId: firestoreId);
      await _db.insertRentalRequest(localRequest);

      await refreshAllData();
      setLoading(false);
      return true;
    } catch (e) {
      print("Error sending rental request: $e");
      setLoading(false);
      return false;
    }
  }

  Future<bool> approveRentalRequest({
    required RentalRequestModel request,
    required double roomPrice,
    required int durationMonths,
    required double initialElectricity,
    required double initialWater,
  }) async {
    if (request.firestoreId == null || request.id == null) return false;
    setLoading(true);
    try {
      // 1. Sync approval on Cloud Firestore
      await FirestoreSyncService.approveRentalRequest(
        firestoreRequestId: request.firestoreId!,
        tenantUid: request.userUid,
        fullName: request.fullName,
        phone: request.phone,
        cccd: request.cccd,
        hometown: request.hometown,
        startDate: request.startDate,
        roomId: request.roomId,
        roomNumber: request.roomNumber,
        roomPrice: roomPrice,
        durationMonths: durationMonths,
        initialElectricity: initialElectricity,
        initialWater: initialWater,
      );

      // 2. Apply approval transaction in local SQLite
      await _db.localApproveRentalRequest(
        requestId: request.id!,
        tenantUid: request.userUid,
        fullName: request.fullName,
        phone: request.phone,
        cccd: request.cccd,
        hometown: request.hometown,
        startDate: request.startDate,
        roomId: request.roomId,
        durationMonths: durationMonths,
        initialElectricity: initialElectricity,
        initialWater: initialWater,
      );

      await refreshAllData();
      setLoading(false);
      return true;
    } catch (e) {
      print("Error approving rental request: $e");
      setLoading(false);
      return false;
    }
  }

  Future<bool> rejectRentalRequest(RentalRequestModel request) async {
    if (request.firestoreId == null || request.id == null) return false;
    setLoading(true);
    try {
      // 1. Sync rejection on Cloud Firestore
      await FirestoreSyncService.rejectRentalRequest(
        firestoreRequestId: request.firestoreId!,
        tenantUid: request.userUid,
        roomNumber: request.roomNumber,
      );

      // 2. Apply rejection locally in SQLite
      await _db.localRejectRentalRequest(request.id!);

      await refreshAllData();
      setLoading(false);
      return true;
    } catch (e) {
      print("Error rejecting rental request: $e");
      setLoading(false);
      return false;
    }
  }
}

class PasswordChangeResult {
  const PasswordChangeResult._({required this.success, this.errorMessage});

  const PasswordChangeResult.success() : this._(success: true);

  const PasswordChangeResult.failure(String message)
    : this._(success: false, errorMessage: message);

  final bool success;
  final String? errorMessage;
}
